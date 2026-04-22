defmodule ChessWeb.Leaderboard.ErrorState do
  use ChessWeb, :html

  def error_state(assigns) do
    ~H"""
    <%= if @error do %>
      <div class="p-4 rounded-box border border-error/30 bg-error/5 text-error text-sm text-center">
        <.icon name="hero-exclamation-triangle" class="size-5 mb-1" />
        <p>{@error}</p>
        <button
          phx-click="retry"
          class="mt-2 text-xs underline hover:no-underline cursor-pointer"
        >
          Try again
        </button>
      </div>
    <% end %>
    """
  end
end
