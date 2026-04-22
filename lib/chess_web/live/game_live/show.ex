defmodule ChessWeb.GameLive.Show do
  use ChessWeb, :live_view
  alias Chess.Games
  alias Chess.Messages
  alias Chess.ChessEngine
  alias Chess.Accounts

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-xl w-full mx-auto flex flex-col gap-3">
        <%!-- Opponent bar --%>
        <div class="flex items-center gap-3 p-3 bg-base-100 border border-base-300 rounded-box">
          <div class="w-9 h-9 rounded-full bg-info/10 text-info flex items-center justify-center text-sm font-medium shrink-0 overflow-hidden">
            <%= if @opponent && @opponent.profile_image do %>
              <img src={@opponent.profile_image} class="w-full h-full object-cover" />
            <% else %>
              {opponent_initials(@opponent)}
            <% end %>
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-base-content truncate flex items-center gap-1.5">
              {opponent_name(@opponent)}
              <%= if @opponent && @game.user_id == @opponent.id do %>
                <span class="text-[10px] bg-base-300 text-base-content/60 px-1.5 py-0.5 rounded font-normal">
                  creator
                </span>
              <% end %>
            </p>
            <p class="text-xs text-base-content/50 font-mono">
              {opponent_color_label(@my_color)}
              <%= if @opponent && @active_color != @my_color && @game.status == "playing" do %>
                · <span class="text-warning">their turn</span>
              <% end %>
            </p>
          </div>
          <div class={[
            "font-mono text-lg font-medium px-3 py-1.5 rounded-field border text-center min-w-[70px] transition-colors",
            if(@opponent && @active_color != @my_color && @game.status == "playing",
              do: "bg-primary text-primary-content border-primary",
              else: "bg-base-200 text-base-content border-base-300"
            )
          ]}>
            {format_time(opponent_time_ms(@my_color, @white_ms, @black_ms))}
          </div>
        </div>

        <%!-- Board --%>
        <div class="relative w-full">
          <ChessWeb.BoardComponent.board
            fen={@game.fen}
            selected={@selected}
            hints={@hints}
            flipped={@flipped}
          />
        </div>

        <%!-- My bar --%>
        <div class="flex items-center gap-3 p-3 bg-base-100 border border-base-300 rounded-box">
          <div class="w-9 h-9 rounded-full bg-success/10 text-success flex items-center justify-center text-sm font-medium shrink-0 overflow-hidden">
            <%= if @current_scope.user.profile_image do %>
              <img src={@current_scope.user.profile_image} class="w-full h-full object-cover" />
            <% else %>
              {user_initials(@current_scope.user)}
            <% end %>
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-base-content truncate flex items-center gap-1.5">
              {@current_scope.user.username}
              <span class="text-xs text-base-content/40 font-normal">(you)</span>
              <%= if @game.user_id == @my_id do %>
                <span class="text-[10px] bg-base-300 text-base-content/60 px-1.5 py-0.5 rounded font-normal">
                  creator
                </span>
              <% end %>
            </p>
            <p class="text-xs text-base-content/50 font-mono">
              {my_color_label(@my_color)}
              <%= if @active_color == @my_color && @game.status == "playing" do %>
                · <span class="text-success">your turn</span>
              <% end %>
            </p>
          </div>
          <div class={[
            "font-mono text-lg font-medium px-3 py-1.5 rounded-field border text-center min-w-[70px] transition-colors",
            if(@active_color == @my_color && @game.status == "playing",
              do: "bg-primary text-primary-content border-primary",
              else: "bg-base-200 text-base-content border-base-300"
            )
          ]}>
            {format_time(my_time_ms(@my_color, @white_ms, @black_ms))}
          </div>
        </div>

        <%!-- Action buttons --%>
        <div class="grid grid-cols-3 gap-2">
          <button
            phx-click="flip_board"
            class="flex items-center justify-center gap-1.5 px-3 py-2 cursor-pointer text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-base-200 transition-colors"
          >
            <.icon name="hero-arrow-uturn-down" class="size-4" /> Flip
          </button>
          <button
            phx-click="resign"
            phx-confirm="Are you sure you want to resign?"
            disabled={@game.status != "playing"}
            class="flex items-center justify-center gap-1.5 px-2 py-2 cursor-pointer text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-error/10 hover:border-error hover:text-error transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
          >
            <.icon name="hero-flag" class="size-4" /> Resign
          </button>
          <button
            phx-click="offer_draw"
            disabled={@game.status != "playing"}
            class="flex items-center justify-center gap-1.5 px-2 py-2 cursor-pointer text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-warning/10 hover:border-warning hover:text-warning transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
          >
            <.icon name="hero-equals" class="size-4" /> Draw
          </button>

          <.link
            navigate={~p"/"}
            class="col-span-3 flex items-center justify-center gap-1.5 px-3 py-2 cursor-pointer text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-base-200 transition-colors"
          >
            <.icon name="hero-arrow-left" class="size-4" /> Exit to Lobby
          </.link>
        </div>

        <%!-- Status banner --%>
        <%= if @game.status != "playing" do %>
          <div class="p-3 rounded-box bg-warning/10 border border-warning text-warning text-sm text-center font-medium">
            {status_label(@game.status)}
          </div>
        <% end %>

        <%!-- Waiting banner with copy link --%>
        <%= if is_nil(@opponent) && @game.status == "playing" do %>
          <div class="p-3 rounded-box bg-info/10 border border-info text-info text-sm">
            <p class="text-center font-medium mb-2">Waiting for opponent — share this link:</p>
            <div class="flex items-center gap-2">
              <input
                type="text"
                readonly
                value={@game_url}
                class="flex-1 text-xs font-mono bg-base-100 border border-info/40 rounded-field px-2 py-1.5 text-base-content outline-none"
              />
              <button
                id="copy-btn"
                phx-hook="CopyToClipboard"
                data-url={@game_url}
                class="shrink-0 px-3 py-1.5 text-xs border border-info rounded-field bg-info/10 text-info hover:bg-info/20 transition-colors cursor-pointer"
              >
                {if @copied, do: "Copied!", else: "Copy"}
              </button>
            </div>
          </div>
        <% end %>

        <%!-- Move log --%>
        <div class="border border-base-300 rounded-box overflow-hidden bg-base-100">
          <div class="flex items-center justify-between px-4 py-2 border-b border-base-300 text-xs font-medium text-base-content/40 uppercase tracking-wider bg-base-200">
            <span>Move history</span>
            <span class="flex items-center gap-1.5">
              <span class="w-2 h-2 rounded-full bg-success animate-pulse"></span> Live
            </span>
          </div>
          <div class="grid grid-cols-[28px_1fr_1fr] font-mono text-xs max-h-40 overflow-y-auto">
            <%= for {pair, index} <- Enum.chunk_every(@game.moves, 2) |> Enum.with_index(1) do %>
              <div class="px-2 py-1 text-base-content/40 border-r border-base-300">{index}.</div>
              <div class="px-2 py-1 text-base-content">{Enum.at(pair, 0)}</div>
              <div class={[
                "px-2 py-1",
                length(@game.moves) == index * 2 && "bg-primary/10 text-primary font-medium"
              ]}>
                {Enum.at(pair, 1, "")}
              </div>
            <% end %>
            <%= if @game.moves == [] do %>
              <div class="col-span-3 px-3 py-4 text-center text-base-content/30 text-xs">
                No moves yet
              </div>
            <% end %>
          </div>
        </div>

        <%!-- Chat --%>
        <.live_component
          module={ChessWeb.Chat.ChatLiveComponent}
          id="chat"
          game={@game}
          my_id={@my_id}
          current_scope={@current_scope}
        />
      </div>
    </Layouts.app>
    """
  end

  # Mount
  def mount(%{"slug" => slug}, _session, socket) do
    current_scope = socket.assigns.current_scope
    my_id = current_scope.user.id

    case Games.get_game_by_slug!(slug) do
      nil ->
        {:ok, redirect(socket, to: "/")}

      game ->
        if connected?(socket) do
          Messages.subscribe_messages(slug)
          Phoenix.PubSub.subscribe(Chess.PubSub, "game:#{slug}")
        end

        game = maybe_claim_white(game, my_id)

        game = maybe_join_as_black(game, my_id)

        if connected?(socket), do: schedule_tick()

        my_color = my_color(game, my_id)
        opponent = load_opponent(game, my_id)

        game_url = url(socket, ~p"/#{game.slug}")

        socket =
          socket
          |> assign(:page_title, "Match")
          |> assign(:game, game)
          |> assign(:my_id, my_id)
          |> assign(:my_color, my_color)
          |> assign(:active_color, ChessEngine.whose_turn(game.fen))
          |> assign(:opponent, opponent)
          |> assign(:selected, nil)
          |> assign(:hints, [])
          |> assign(:flipped, my_color == :black)
          |> assign(:white_ms, game.white_time_ms)
          |> assign(:black_ms, game.black_time_ms)
          |> assign(:game_url, game_url)
          |> assign(:copied, false)

        {:ok, socket}
    end
  end

  # Events
  def handle_event("square_click", %{"square" => square}, socket) do
    %{game: game, selected: selected, my_color: my_color, active_color: active_color} =
      socket.assigns

    if is_nil(socket.assigns.opponent) or
         game.status != "playing" or
         active_color != my_color do
      {:noreply, socket}
    else
      cond do
        my_piece?(game.fen, square, my_color) ->
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

              Phoenix.PubSub.broadcast(Chess.PubSub, "game:#{game.slug}", {:move, updated_game})

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
        Phoenix.PubSub.broadcast(Chess.PubSub, "game:#{game.slug}", {:move, updated_game})
        {:noreply, assign(socket, :game, updated_game)}

      _ ->
        {:noreply, put_flash(socket, :error, "Could not resign.")}
    end
  end

  def handle_event("offer_draw", _, socket) do
    %{game: game} = socket.assigns

    case Games.declare_draw(game) do
      {:ok, updated_game} ->
        Phoenix.PubSub.broadcast(Chess.PubSub, "game:#{game.slug}", {:move, updated_game})
        {:noreply, assign(socket, :game, updated_game)}

      _ ->
        {:noreply, put_flash(socket, :error, "Could not declare draw.")}
    end
  end

  def handle_event("copied_link", _, socket) do
    Process.send_after(self(), :reset_copied, 2000)
    {:noreply, assign(socket, :copied, true)}
  end

  # Timer
  def handle_info(:tick, socket) do
    %{game: game, active_color: active_color, white_ms: white_ms, black_ms: black_ms} =
      socket.assigns

    if is_nil(socket.assigns.opponent) or game.status != "playing" do
      schedule_tick()
      {:noreply, socket}
    else
      schedule_tick()

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

        Phoenix.PubSub.broadcast(Chess.PubSub, "game:#{game.slug}", {:move, updated_game})

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

  # PubSub + misc
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

    opponent_id =
      cond do
        updated_game.white_id == my_id -> updated_game.black_id
        updated_game.black_id == my_id -> updated_game.white_id
        true -> nil
      end

    {opponent, flash_msg} =
      if opponent_id do
        case Accounts.get_user(opponent_id) do
          nil -> {nil, "Opponent joined! Game starts now."}
          user -> {user, "#{user.username} has joined! Game starts now."}
        end
      else
        {nil, "Opponent joined! Game starts now."}
      end

    {:noreply,
     socket
     |> assign(:game, updated_game)
     |> assign(:opponent, opponent)
     |> put_flash(:info, flash_msg)}
  end

  def handle_info({:new_message, message}, socket) do
    send_update(ChessWeb.Chat.ChatLiveComponent, id: "chat", new_message: message)
    {:noreply, socket}
  end

  def handle_info({:flash, kind, message}, socket) do
    {:noreply, put_flash(socket, kind, message)}
  end

  def handle_info(_msg, socket), do: {:noreply, socket}

  # Private helpers
  defp schedule_tick, do: Process.send_after(self(), :tick, 1000)

  defp maybe_claim_white(game, my_id) do
    if is_nil(game.white_id) do
      case Games.join_as_white(game, my_id) do
        {:ok, updated_game} -> updated_game
        {:error, _} -> game
      end
    else
      game
    end
  end

  defp maybe_join_as_black(game, my_id) do
    cond do
      not is_nil(game.black_id) ->
        game

      game.white_id == my_id ->
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

  defp my_color(game, my_id) do
    cond do
      game.white_id == my_id -> :white
      game.black_id == my_id -> :black
      true -> :white
    end
  end

  defp load_opponent(game, my_id) do
    opponent_id =
      cond do
        game.white_id == my_id -> game.black_id
        game.black_id == my_id -> game.white_id
        true -> nil
      end

    if opponent_id, do: Accounts.get_user(opponent_id), else: nil
  end

  defp my_piece?(fen, square, my_color) do
    piece = ChessWeb.BoardComponent.fen_to_board(fen)[square]

    case my_color do
      :white -> piece && piece == String.upcase(piece) && piece != String.downcase(piece)
      :black -> piece && piece == String.downcase(piece) && piece != String.upcase(piece)
    end
  end

  defp my_time_ms(:white, white_ms, _), do: white_ms
  defp my_time_ms(:black, _, black_ms), do: black_ms

  defp opponent_time_ms(:white, _, black_ms), do: black_ms
  defp opponent_time_ms(:black, white_ms, _), do: white_ms

  defp format_time(ms) when ms <= 0, do: "00:00"

  defp format_time(ms) do
    total_seconds = div(ms, 1000)
    minutes = div(total_seconds, 60)
    seconds = rem(total_seconds, 60)
    :io_lib.format("~2..0B:~2..0B", [minutes, seconds]) |> to_string()
  end

  defp opponent_name(nil), do: "Waiting for opponent..."
  defp opponent_name(%{username: username}), do: username

  defp opponent_initials(nil), do: "?"

  defp opponent_initials(%{username: username}),
    do: username |> String.upcase() |> String.slice(0, 2)

  defp user_initials(%{username: username}), do: username |> String.upcase() |> String.slice(0, 2)

  defp my_color_label(:white), do: "White"
  defp my_color_label(:black), do: "Black"

  defp opponent_color_label(:white), do: "Black"
  defp opponent_color_label(:black), do: "White"

  defp status_label("checkmate"), do: "Checkmate!"
  defp status_label("draw"), do: "Draw agreed"
  defp status_label("timeout_white_wins"), do: "White wins on time!"
  defp status_label("timeout_black_wins"), do: "Black wins on time!"
  defp status_label("resigned_white_wins"), do: "White wins — Black resigned"
  defp status_label("resigned_black_wins"), do: "Black wins — White resigned"
  defp status_label(_), do: ""
end
