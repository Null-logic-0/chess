defmodule ChessWeb.GameLive.Show do
  @moduledoc """
  LiveView responsible for rendering and orchestrating a real-time chess game session.

  This module is the central coordination point between:
    * Game state (`Chess.Games`)
    * Chess rules engine (`Chess.ChessEngine`)
    * Real-time communication (`ChessWeb.GameLive.GamePubSub`)
    * UI helper layer (`ChessWeb.GameLive.Helpers`)
    * Presentation components (PlayerCard, MoveLog, etc.)

  ## Responsibilities

    * Initialize game session state on mount
    * Handle user interactions (move selection, resign, draw, board flip)
    * Synchronize real-time updates via PubSub
    * Manage player timing (basic client-side ticking)
    * Maintain UI state (selection, hints, orientation, flash messages)

  ## State ownership

  This LiveView owns *ephemeral UI state*, including:
    * Selected square (`:selected`)
    * Legal move hints (`:hints`)
    * Board orientation (`:flipped`)
    * Local clock state (`:white_ms`, `:black_ms`)
    * UI feedback (`:copied`, flash messages)

  It does NOT own authoritative game state — that resides in `Chess.Games`.

  ## PubSub events consumed

    * `{:move, game}` — opponent or self move update
    * `{:opponent_joined, game}` — second player joins
    * `{:new_message, message}` — chat system integration

  ## PubSub events emitted

    * `{:move, game}` (via `GamePubSub.broadcast_move/2`)
    * `{:opponent_joined, game}`

  ## Time system

  A simple tick-based countdown (1s interval) updates client-side clocks.
  Timeouts are enforced client-side and persisted via `Games.update_game_times/4`.

  ## Important notes

  This LiveView is intentionally "stateful and busy".
  If complexity increases further, it should be split into:
    * a `GameSession` orchestrator (business flow)
    * a thinner LiveView (pure UI layer)

  """
  use ChessWeb, :live_view

  alias Chess.Games
  alias Chess.ChessEngine
  alias ChessWeb.GameLive.Helpers
  alias ChessWeb.GameLive.GamePubSub

  import ChessWeb.Game.PlayerCard
  import ChessWeb.Game.ActionButtons
  import ChessWeb.Game.StatusBanner
  import ChessWeb.Game.ShareLink
  import ChessWeb.Game.MoveLog

  @doc """
  Mounts a game session LiveView.

  Responsibilities:
    * Load game by slug
    * Identify current user perspective
    * Join game as white/black if applicable
    * Subscribe to PubSub streams
    * Initialize UI state
    * Start local clock ticking
  """
  def mount(%{"slug" => slug}, _session, socket) do
    current_scope = socket.assigns.current_scope
    my_id = current_scope.user.id

    case Games.get_game_by_slug!(slug) do
      nil ->
        {:ok, redirect(socket, to: "/")}

      game ->
        if connected?(socket), do: GamePubSub.subscribe(slug)

        game = GamePubSub.maybe_claim_white(game, my_id)
        game = GamePubSub.maybe_join_as_black(game, my_id, connected?(socket))

        if connected?(socket), do: schedule_tick()

        socket =
          socket
          |> assign(:page_title, "Match")
          |> assign(:game, game)
          |> assign(:my_id, my_id)
          |> assign(:my_color, Helpers.my_color(game, my_id))
          |> assign(:active_color, ChessEngine.whose_turn(game.fen))
          |> assign(:opponent, Helpers.load_opponent(game, my_id))
          |> assign(:selected, nil)
          |> assign(:hints, [])
          |> assign(:flipped, Helpers.my_color(game, my_id) == :black)
          |> assign(:white_ms, game.white_time_ms)
          |> assign(:black_ms, game.black_time_ms)
          |> assign(:game_url, url(socket, ~p"/#{game.slug}"))
          |> assign(:copied, false)

        {:ok, socket}
    end
  end

  def handle_event("square_click", %{"square" => square}, socket) do
    %{game: game, selected: selected, my_color: my_color, active_color: active_color} =
      socket.assigns

    if is_nil(socket.assigns.opponent) or
         game.status != "playing" or
         active_color != my_color do
      {:noreply, socket}
    else
      cond do
        Helpers.my_piece?(game.fen, square, my_color) ->
          hints = Games.legal_moves_from(game, square)
          {:noreply, assign(socket, selected: square, hints: hints)}

        selected != nil and square in socket.assigns.hints ->
          uci = selected <> square

          case Games.apply_move(game, uci) do
            {:ok, updated_game} ->
              {:ok, updated_game} =
                Games.update_game_times(
                  updated_game,
                  socket.assigns.white_ms,
                  socket.assigns.black_ms,
                  updated_game.status
                )

              GamePubSub.broadcast_move(game.slug, updated_game)

              {:noreply,
               socket
               |> assign(:game, updated_game)
               |> assign(:selected, nil)
               |> assign(:hints, [])
               |> assign(:active_color, ChessEngine.whose_turn(updated_game.fen))
               |> assign(:white_ms, updated_game.white_time_ms)
               |> assign(:black_ms, updated_game.black_time_ms)}

            {:error, _} ->
              {:noreply, assign(socket, selected: nil, hints: [])}
          end

        true ->
          {:noreply, assign(socket, selected: nil, hints: [])}
      end
    end
  end

  def handle_event("flip_board", _, socket) do
    {:noreply, update(socket, :flipped, &(!&1))}
  end

  def handle_event("resign", _, socket) do
    %{game: game, my_color: my_color} = socket.assigns

    case Games.resign(game, my_color) do
      {:ok, updated_game} ->
        GamePubSub.broadcast_move(game.slug, updated_game)
        {:noreply, assign(socket, :game, updated_game)}

      _ ->
        {:noreply, put_flash(socket, :error, "Could not resign.")}
    end
  end

  def handle_event("offer_draw", _, socket) do
    %{game: game} = socket.assigns

    case Games.declare_draw(game) do
      {:ok, updated_game} ->
        GamePubSub.broadcast_move(game.slug, updated_game)
        {:noreply, assign(socket, :game, updated_game)}

      _ ->
        {:noreply, put_flash(socket, :error, "Could not declare draw.")}
    end
  end

  def handle_event("copied_link", _, socket) do
    Process.send_after(self(), :reset_copied, 2000)
    {:noreply, assign(socket, :copied, true)}
  end

  def handle_info(:tick, socket) do
    %{game: game, active_color: active_color, white_ms: white_ms, black_ms: black_ms} =
      socket.assigns

    schedule_tick()

    if is_nil(socket.assigns.opponent) or game.status != "playing" do
      {:noreply, socket}
    else
      {new_white_ms, new_black_ms} =
        case active_color do
          :white -> {white_ms - 1000, black_ms}
          :black -> {white_ms, black_ms - 1000}
        end

      if new_white_ms <= 0 or new_black_ms <= 0 do
        loser = if new_white_ms <= 0, do: :white, else: :black
        winner = if loser == :white, do: "black_wins", else: "white_wins"

        {:ok, updated_game} =
          Games.update_game_times(
            game,
            max(new_white_ms, 0),
            max(new_black_ms, 0),
            "timeout_#{winner}"
          )

        GamePubSub.broadcast_move(game.slug, updated_game)

        {:noreply,
         socket
         |> assign(:game, updated_game)
         |> assign(:white_ms, 0)
         |> assign(:black_ms, 0)}
      else
        {:noreply,
         socket
         |> assign(:white_ms, new_white_ms)
         |> assign(:black_ms, new_black_ms)}
      end
    end
  end

  def handle_info(:reset_copied, socket) do
    {:noreply, assign(socket, :copied, false)}
  end

  def handle_info({:move, updated_game}, socket) do
    {:noreply,
     socket
     |> assign(:game, updated_game)
     |> assign(:selected, nil)
     |> assign(:hints, [])
     |> assign(:active_color, ChessEngine.whose_turn(updated_game.fen))
     |> assign(:white_ms, updated_game.white_time_ms)
     |> assign(:black_ms, updated_game.black_time_ms)}
  end

  def handle_info({:opponent_joined, updated_game}, socket) do
    my_id = socket.assigns.my_id

    if updated_game.black_id == my_id do
      {:noreply,
       socket
       |> assign(:game, updated_game)
       |> assign(:opponent, Helpers.load_opponent(updated_game, my_id))}
    else
      opponent = Helpers.load_opponent(updated_game, my_id)

      flash_msg =
        if opponent,
          do: "#{opponent.full_name} has joined! Game starts now.",
          else: "Opponent joined! Game starts now."

      Process.send_after(self(), :clear_flash, 3000)

      {:noreply,
       socket
       |> assign(:game, updated_game)
       |> assign(:opponent, opponent)
       |> put_flash(:info, flash_msg)}
    end
  end

  def handle_info({:new_message, message}, socket) do
    send_update(ChessWeb.Chat.ChatLiveComponent, id: "chat", new_message: message)

    socket =
      if to_string(message.user_id) != to_string(socket.assigns.my_id) do
        Process.send_after(self(), :clear_flash, 3000)

        put_flash(
          socket,
          :info,
          "#{message.user.full_name}: #{String.slice(message.content, 0, 60)}"
        )
      else
        socket
      end

    {:noreply, socket}
  end

  def handle_info(:clear_flash, socket) do
    {:noreply, clear_flash(socket)}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  defp schedule_tick, do: Process.send_after(self(), :tick, 1000)
end
