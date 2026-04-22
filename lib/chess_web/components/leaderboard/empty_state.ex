defmodule ChessWeb.Leaderboard.EmptyState do
  use ChessWeb, :html

  def empty_state(assigns) do
    ~H"""
    <div class="border border-base-300 rounded-box p-12 flex flex-col items-center gap-3 text-center">
      <.icon name="hero-trophy" class="size-10 text-base-content/20" />
      <p class="text-base-content/50 text-sm">
        No players yet. Play some games to appear here!
      </p>
    </div>
    """
  end
end
