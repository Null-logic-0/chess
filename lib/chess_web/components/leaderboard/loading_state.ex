defmodule ChessWeb.Leaderboard.LoadingState do
  use ChessWeb, :html

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
