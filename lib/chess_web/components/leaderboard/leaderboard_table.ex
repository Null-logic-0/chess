defmodule ChessWeb.Leaderboard.LeaderboardTable do
  @moduledoc """
  Provides a reusable component for rendering the leaderboard table.

  This component displays a ranked list of players along with their game
  statistics (wins, losses, draws). It highlights the current user and
  visually distinguishes top-ranked players.
  """
  use ChessWeb, :html

  @doc """
  Renders the leaderboard table.

  Displays a list of players with ranking position, profile information,
  and match statistics. The current user is visually highlighted, and the
  top three players are marked with medal indicators.

  ## Attributes

    * `:players` - A list of player maps or structs. Each player is expected
      to include:
        * `:id`
        * `:full_name`
        * `:profile_image`
        * `:wins`
        * `:losses`
        * `:draws`

    * `:current_user` - The currently authenticated user map or struct.
      Used to highlight the user's row in the leaderboard.

  ## Examples

      <.leaderboard_table players={@players} current_user={@current_user} />

  """
  attr :players, :list,
    required: true,
    doc: "List of players to display in the leaderboard."

  attr :current_user, :map,
    required: true,
    doc: "Current user used for highlighting their row."

  def leaderboard_table(assigns) do
    ~H"""
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
          <%= for {player, i} <- Enum.with_index(@players, 1) do %>
            <tr class={[
              "border-t border-base-300 transition-colors",
              if(player.id == @current_user.id, do: "bg-primary/5", else: "hover:bg-base-200")
            ]}>
              <td class="px-4 py-2 font-mono">
                <%= cond do %>
                  <% i == 1 -> %>
                    <span>🥇</span>
                  <% i == 2 -> %>
                    <span>🥈</span>
                  <% i == 3 -> %>
                    <span>🥉</span>
                  <% true -> %>
                    <span class="text-base-content/40">{i}</span>
                <% end %>
              </td>
              <td class="px-4 py-2">
                <div class="flex items-center gap-2">
                  <div class="w-7 h-7 rounded-full overflow-hidden bg-base-300 shrink-0">
                    <img src={player.profile_image} class="w-full h-full object-cover" />
                  </div>
                  <span class={[
                    "font-medium",
                    if(player.id == @current_user.id, do: "text-primary", else: "text-base-content")
                  ]}>
                    {player.full_name}
                    <%= if player.id == @current_user.id do %>
                      <span class="text-xs text-base-content/40 font-normal">(you)</span>
                    <% end %>
                  </span>
                </div>
              </td>
              <td class="px-4 py-2 text-center text-success font-mono">{player.wins}</td>
              <td class="px-4 py-2 text-center text-error font-mono">{player.losses}</td>
              <td class="px-4 py-2 text-center text-base-content/50 font-mono">{player.draws}</td>
            </tr>
          <% end %>
        </tbody>
      </table>
    </div>
    """
  end
end
