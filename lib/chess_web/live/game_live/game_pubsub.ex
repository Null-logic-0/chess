defmodule ChessWeb.GameLive.GamePubSub do
  @moduledoc """
  Handles PubSub communication and lightweight game-session side effects
  for the Chess LiveView layer.

  This module acts as a bridge between:
    * The Games domain (`Chess.Games`)
    * The messaging system (`Chess.Messages`)
    * Phoenix PubSub topics used by LiveView processes

  It is intentionally thin and UI-oriented — it should not contain business
  rules beyond safe "join-if-possible" guards.

  ## Responsibilities

    * Subscribe LiveView processes to game-related topics
    * Broadcast real-time game updates (moves, opponent joins)
    * Coordinate lightweight player assignment (white/black) in a safe way

  ## PubSub Topics

    * `"game:{slug}"` — core game event stream
    * Messages topic is delegated to `Chess.Messages`

  ## Event types

    * `{:move, game}` — emitted after a move is made
    * `{:opponent_joined, game}` — emitted when a second player joins

  ## Notes

  This module intentionally mixes:
    * domain calls (`Chess.Games`)
    * PubSub broadcasts

  This is acceptable at the LiveView boundary, but should NOT grow into
  full business logic. If complexity increases, move orchestration into
  a dedicated context (e.g. `Chess.GameSession`).
  """

  alias Chess.Games
  alias Chess.Messages

  @pubsub Chess.PubSub

  @doc """
  Subscribes the current process to all real-time updates for a game session.

  This includes:
    * Game event stream (`game:slug`)
    * Chat/messages stream via `Chess.Messages`

  ## Examples

      GamePubSub.subscribe("abc123")
  """
  def subscribe(slug) do
    Messages.subscribe_messages(slug)
    Phoenix.PubSub.subscribe(@pubsub, "game:#{slug}")
  end

  @doc """
  Broadcasts a move update to all subscribers of a game.

  This is used after a successful move has been persisted and validated.

  ## Events emitted

      {:move, updated_game}

  ## Examples

      GamePubSub.broadcast_move(game.slug, game)
  """
  def broadcast_move(slug, updated_game) do
    Phoenix.PubSub.broadcast(@pubsub, "game:#{slug}", {:move, updated_game})
  end

  @doc """
  Attempts to assign the current user as White if the slot is empty.

  This is a *best-effort assignment* and will silently fail if:
    * White is already taken
    * The database update fails

  Returns the original or updated game struct.

  ## Examples

      GamePubSub.maybe_claim_white(game, user_id)
  """
  def maybe_claim_white(game, my_id) do
    if is_nil(game.white_id) do
      case Games.join_as_white(game, my_id) do
        {:ok, updated_game} -> updated_game
        {:error, _} -> game
      end
    else
      game
    end
  end

  @doc """
  Attempts to assign the current user as Black under safe conditions.

  Conditions:
    * Black must be unassigned
    * User cannot already be White
    * User must be actively connected
    * Database update must succeed

  If successful, broadcasts `{:opponent_joined, game}`.

  Returns:
    * updated game if join succeeds
    * original game otherwise
  """
  def maybe_join_as_black(game, my_id, connected?) do
    cond do
      not is_nil(game.black_id) ->
        game

      game.white_id == my_id ->
        game

      not connected? ->
        game

      true ->
        case Games.join_as_black(game, my_id) do
          {:ok, updated_game} ->
            Phoenix.PubSub.broadcast(
              Chess.PubSub,
              "game:#{game.slug}",
              {:opponent_joined, updated_game}
            )

            updated_game

          {:error, _} ->
            game
        end
    end
  end
end
