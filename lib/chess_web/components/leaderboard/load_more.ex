defmodule ChessWeb.Leaderboard.LoadMore do
  use ChessWeb, :html

  def load_more(assigns) do
    ~H"""
    <%= if @end_of_list do %>
      <p class="text-center text-xs text-base-content/30 py-2">You've reached the end</p>
    <% else %>
      <button
        phx-click="load_more"
        class="w-full py-2 text-sm border border-base-300 rounded-box text-base-content/50 hover:bg-base-200 transition-colors cursor-pointer"
      >
        Load more
      </button>
    <% end %>
    """
  end
end
