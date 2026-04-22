defmodule ChessWeb.Leaderboard.LoadingState do
  @moduledoc """
  Provides a reusable loading skeleton for the leaderboard table.

  This component is displayed while leaderboard data is being fetched.
  It uses skeleton rows to preserve layout stability and improve perceived performance.
  """

  use ChessWeb, :html

  @doc """
  Renders a loading skeleton for the leaderboard.

  Displays placeholder rows that mimic the structure of the final leaderboard table
  while data is being fetched from the server. This prevents layout shift and
  improves user experience during loading states.

  ## Attributes

    * `:loading` - A boolean flag indicating whether the loading state should be shown.
      When `true`, skeleton rows are rendered. When `false`, nothing is displayed.

  ## Examples

      <.loading_state loading={@loading} />

  """

  attr :loading, :boolean,
    required: true,
    doc: "Controls whether the loading skeleton is displayed."

  def loading_state(assigns) do
    ~H"""
    <%= if @loading do %>
      <div class="border border-base-300 rounded-box overflow-hidden">
        <table class="w-full text-sm">
          <thead class="bg-base-200 text-base-content/50 uppercase text-xs tracking-wider">
            <tr>
              <th class="px-4 py-2 text-left">#</th>
              <th class="px-4 py-2 text-left">Player</th>
              <th class="px-4 py-2 text-center">W</th>
              <th class="px-4 py-2 text-center">L</th>
              <th class="px-4 py-2 text-center">D</th>
            </tr>
          </thead>
          <tbody>
            <%= for _ <- 1..8 do %>
              <tr class="border-t border-base-300">
                <td class="px-4 py-3">
                  <div class="h-3 w-4 bg-base-300 rounded animate-pulse" />
                </td>
                <td class="px-4 py-3">
                  <div class="flex items-center gap-2">
                    <div class="w-7 h-7 rounded-full bg-base-300 animate-pulse shrink-0" />
                    <div class="h-3 w-24 bg-base-300 rounded animate-pulse" />
                  </div>
                </td>
                <td class="px-4 py-3">
                  <div class="h-3 w-6 bg-base-300 rounded animate-pulse mx-auto" />
                </td>
                <td class="px-4 py-3">
                  <div class="h-3 w-6 bg-base-300 rounded animate-pulse mx-auto" />
                </td>
                <td class="px-4 py-3">
                  <div class="h-3 w-6 bg-base-300 rounded animate-pulse mx-auto" />
                </td>
              </tr>
            <% end %>
          </tbody>
        </table>
      </div>
    <% end %>
    """
  end
end
