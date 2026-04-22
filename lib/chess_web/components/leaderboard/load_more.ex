defmodule ChessWeb.Leaderboard.LoadMore do
  @moduledoc """
  Provides a reusable component for handling incremental pagination in the leaderboard.

  This component renders either a "Load more" button or an end-of-list indicator,
  depending on whether additional data is available.
  """
  use ChessWeb, :html

  @doc """
  Renders the load more control or end-of-list message.

  Displays a button that triggers a `"load_more"` event when more data is available.
  If the end of the dataset has been reached, a simple informational message is shown instead.

  ## Attributes

    * `:end_of_list` - A boolean indicating whether all data has been loaded.
      When `true`, the component renders an end-of-list message instead of the button.

  ## Examples

      <.load_more end_of_list={@end_of_list} />

  """

  attr :end_of_list, :boolean,
    required: true,
    doc: "Whether all data has been loaded."

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
