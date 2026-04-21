defmodule ChessWeb.GameLive.Show do
  use ChessWeb, :live_view
  alias Chess.Games
  alias Chess.Messages

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-xl w-full mx-auto flex flex-col gap-3">
        <%!-- Opponent bar --%>
        <div class="flex items-center gap-3 p-3 bg-base-100 border border-base-300 rounded-box">
          <div class="w-9 h-9 rounded-full bg-info/10 text-info flex items-center justify-center text-sm font-medium shrink-0">
            JD
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-base-content truncate">jane_doe</p>
            <p class="text-xs text-base-content/50 font-mono">1842 elo · Black</p>
          </div>
          <div class="font-mono text-lg font-medium px-3 py-1.5 rounded-field border border-base-300 text-center min-w-[70px] bg-base-200 text-base-content">
            04:00
          </div>
        </div>

        <%!-- Board --%>
        <div class="relative w-full">
          <img src="/images/board.png" class="w-full rounded-box border border-base-300 shadow-xl" />
        </div>

        <%!-- My bar --%>
        <div class="flex items-center gap-3 p-3 bg-base-100 border border-base-300 rounded-box">
          <div class="w-9 h-9 rounded-full bg-success/10 text-success flex items-center justify-center text-sm font-medium shrink-0">
            JD
          </div>
          <div class="flex-1 min-w-0">
            <p class="text-sm font-medium text-base-content truncate">
              john_doe <span class="text-xs text-base-content/40 font-normal">(you)</span>
            </p>
            <p class="text-xs text-base-content/50 font-mono">1795 elo · White</p>
          </div>
          <div class="font-mono text-lg font-medium px-3 py-1.5 rounded-field border text-center min-w-[70px] bg-primary text-primary-content border-primary">
            02:00
          </div>
        </div>

        <div class="grid grid-cols-3 gap-4">
          <button class="px-3 py-1.5 cursor-pointer text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-base-200 transition-colors">
            <.icon name="hero-arrow-uturn-down" class="size-4" /> Flip
          </button>
          <button class="px-2 py-1.5 cursor-pointer text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-base-200 transition-colors">
            <.icon name="hero-flag" class="size-4" /> Resign
          </button>
          <button class="px-2 py-1.5 cursor-pointer text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-base-200 transition-colors">
            <.icon name="hero-equals" class="size-4" /> Draw
          </button>
        </div>

        <%!-- Move log --%>
        <div class="border border-base-300 rounded-box overflow-hidden bg-base-100">
          <div class="flex items-center justify-between px-4 py-2 border-b border-base-300 text-xs font-medium text-base-content/40 uppercase tracking-wider bg-base-200">
            <span>Move history</span>
            <span class="flex items-center gap-1.5">
              <span class="w-2 h-2 rounded-full bg-success"></span> Live
            </span>
          </div>
          <div class="grid grid-cols-[28px_1fr_1fr] font-mono text-xs">
            <div class="px-2 py-1 text-base-content/40 border-r border-base-300">1.</div>
            <div class="px-2 py-1 text-base-content">e4</div>
            <div class="px-2 py-1 text-base-content">e5</div>
            <div class="px-2 py-1 text-base-content/40 border-r border-base-300">2.</div>
            <div class="px-2 py-1 text-base-content">Nf3</div>
            <div class="px-2 py-1 bg-primary/10 text-primary font-medium">Nc6</div>
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

  def mount(%{"slug" => slug}, _session, socket) do
    current_scope = socket.assigns.current_scope
    my_id = to_string(current_scope.user.id)

    case Games.get_game_by_slug!(slug) do
      nil ->
        {:ok, redirect(socket, to: "/")}

      game ->
        if connected?(socket) do
          Messages.subscribe_messages(slug)
        end

        socket =
          socket
          |> assign(page_title: "Match")
          |> assign(:game, game)
          |> assign(:my_id, my_id)

        {:ok, socket}
    end
  end

  # Chat events

  def handle_info({:new_message, message}, socket) do
    send_update(ChessWeb.Chat.ChatLiveComponent, id: "chat", new_message: message)
    {:noreply, socket}
  end

  def handle_info({:flash, kind, message}, socket) do
    {:noreply, put_flash(socket, kind, message)}
  end

  def handle_info(_msg, socket) do
    {:noreply, socket}
  end
end
