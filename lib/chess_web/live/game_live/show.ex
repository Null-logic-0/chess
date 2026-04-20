defmodule ChessWeb.GameLive.Show do
  use ChessWeb, :live_view
  alias Chess.Games

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

        <%!-- Controls --%>
        <div class="flex gap-2 justify-center flex-wrap">
          <button class="px-3 py-1.5 text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-base-200 transition-colors">
            ⟳ Flip
          </button>
          <button class="px-3 py-1.5 text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-base-200 transition-colors">
            ← Undo
          </button>
          <button class="px-3 py-1.5 text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-base-200 transition-colors">
            ⚑ Resign
          </button>
          <button class="px-3 py-1.5 text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-base-200 transition-colors">
            = Draw
          </button>
          <button class="px-3 py-1.5 text-sm bg-accent text-accent-content rounded-field hover:opacity-90 transition-opacity">
            ⬡ Analyze
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
        <div class="border border-base-300 rounded-box overflow-hidden bg-base-100">
          <div class="flex items-center justify-between px-4 py-2 border-b border-base-300 text-xs font-medium text-base-content/40 uppercase tracking-wider bg-base-200">
            <span>Chat</span>
          </div>

          <%!-- Messages --%>
          <div class="flex flex-col gap-1 p-3 h-36 overflow-y-auto">
            <div class="chat chat-start">
              <div class="chat-image avatar placeholder">
                <div class="w-6 rounded-full bg-info/10 text-info text-xs flex items-center justify-center">
                  JD
                </div>
              </div>
              <div class="chat-bubble chat-bubble-ghost text-base-content text-xs py-1.5 px-3">
                Good luck! 🤝
              </div>
            </div>
            <div class="chat chat-end">
              <div class="chat-image avatar placeholder">
                <div class="w-6 rounded-full bg-success/10 text-success text-xs flex items-center justify-center">
                  JD
                </div>
              </div>
              <div class="chat-bubble chat-bubble-ghost text-base-content text-xs py-1.5 px-3">
                You too, gl hf!
              </div>
            </div>
            <div class="chat chat-start">
              <div class="chat-image avatar placeholder">
                <div class="w-6 rounded-full bg-info/10 text-info text-xs flex items-center justify-center">
                  JD
                </div>
              </div>
              <div class="chat-bubble chat-bubble-ghost text-base-content text-xs py-1.5 px-3">
                Nice move 👀
              </div>
            </div>
          </div>

          <%!-- Input --%>
          <div class="flex items-center gap-2 px-3 py-2 border-t border-base-300 bg-base-200">
            <input
              type="text"
              placeholder="Say something..."
              class="input input-sm flex-1 bg-base-100 border-base-300 text-base-content placeholder:text-base-content/30 focus:outline-none focus:border-primary text-xs"
            />
            <button class="btn btn-sm btn-primary px-3">
              Send
            </button>
          </div>
        </div>

        <p class="text-center text-xs text-base-content/40 font-mono">White to move</p>
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
        socket =
          socket
          |> assign(page_title: "jane_doe vs john_doe")
          |> assign(:game, game)
          |> assign(:my_id, my_id)

        {:ok, socket}
    end
  end
end
