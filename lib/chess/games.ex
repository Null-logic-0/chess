defmodule Chess.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias Chess.Repo

  alias Chess.Games.Game
  alias Chess.ChessEngine
  alias Chess.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any game changes.

  The broadcasted messages match the pattern:

    * {:created, %Game{}}
    * {:updated, %Game{}}
    * {:deleted, %Game{}}

  """
  def subscribe_games(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Chess.PubSub, "user:#{key}:games")
  end

  defp broadcast_game(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Chess.PubSub, "user:#{key}:games", message)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(scope, 123)
      %Game{}

      iex> get_game!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(%Scope{} = scope, id) do
    Repo.get_by!(Game, id: id, user_id: scope.user.id)
  end

  @doc """
  Gets a single game by slug.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game_by_slug!("slug")
      %Game{}

      iex> get_game_by_slug!("invalid-slug")
      ** (Ecto.NoResultsError)

  """
  def get_game_by_slug!(slug) do
    Game
    |> where([r], r.slug == ^slug)
    |> preload(:user)
    |> Repo.one()
  end

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(scope, %{field: value})
      {:ok, %Game{}}

      iex> create_game(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

  # def create_game(%Scope{} = scope, attrs \\ %{}) do
  #   with {:ok, game = %Game{}} <-
  #          %Game{}
  #          |> Game.changeset(attrs, scope)
  #          |> Repo.insert() do
  #     broadcast_game(scope, {:created, game})
  #     {:ok, game}
  #   end
  # end

  def create_game(%Scope{} = scope, attrs \\ %{}) do
    with {:ok, game = %Game{}} <-
           %Game{}
           |> Game.changeset(Map.merge(attrs, %{"white_id" => scope.user.id}), scope)
           |> Repo.insert() do
      broadcast_game(scope, {:created, game})
      {:ok, game}
    end
  end

  def join_as_black(game, user_id) do
    game
    |> Game.state_changeset(%{black_id: user_id})
    |> Repo.update()
  end

  @doc "Apply a UCI move to a game, persist it, return updated game."
  def apply_move(game, uci_move) do
    case ChessEngine.apply_move(game.fen, uci_move) do
      {:ok, new_fen} ->
        status =
          case ChessEngine.game_status(new_fen) do
            :checkmate -> "checkmate"
            {:draw, _} -> "draw"
            :playing -> "playing"
          end

        game
        |> Game.state_changeset(%{
          fen: new_fen,
          moves: game.moves ++ [uci_move],
          status: status
        })
        |> Repo.update()

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc "Get legal move destinations for a piece on a given square."
  def legal_moves_from(game, square) do
    ChessEngine.legal_moves_from(game.fen, square)
  end

  def join_as_white(game, user_id) do
    game
    |> Game.state_changeset(%{white_id: user_id})
    |> Repo.update()
  end

  @doc "Resign a game."
  def resign(game, player_color) do
    winner = if player_color == :white, do: "black_wins", else: "white_wins"

    game
    |> Game.state_changeset(%{status: "resigned_#{winner}"})
    |> Repo.update()
  end

  @doc "Declare an immediate draw."
  def declare_draw(game) do
    game
    |> Game.state_changeset(%{status: "draw"})
    |> Repo.update()
  end

  @doc "Update clock times and status (called every tick)."
  def update_game_times(game, white_ms, black_ms, status) do
    game
    |> Game.state_changeset(%{
      white_time_ms: max(white_ms, 0),
      black_time_ms: max(black_ms, 0),
      status: status
    })
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(scope, game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game(%Scope{} = scope, %Game{} = game, attrs \\ %{}) do
    true = game.user_id == scope.user.id

    Game.changeset(game, attrs, scope)
  end
end
