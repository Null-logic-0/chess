defmodule ChessWeb.Leaderboard.MyStats do
  @moduledoc """
  Displays the current user's personal leaderboard statistics.

  This component highlights the authenticated user's rank and game performance,
  including wins, losses, and draws. It is typically shown above the leaderboard
  table to provide quick personal context.
  """
  use ChessWeb, :html

  @doc """
  Renders the current user's leaderboard stats card.

  Shows the user's avatar, name, rank, and game statistics (wins, losses, draws).
  This component is only rendered when `my_stats` data is available.

  ## Attributes

    * `:my_stats` - A map or struct containing user leaderboard statistics:
        * `:rank`
        * `:wins`
        * `:losses`
        * `:draws`

    * `:current_scope` - The current authentication scope containing the user.
      Used to display user identity information (name and profile image).

  ## Examples

      <.my_stats my_stats={@my_stats} current_scope={@current_scope} />

  """
  attr :my_stats, :map,
    required: true,
    doc: "User leaderboard stats (rank, wins, losses, draws)."

  attr :current_scope, :map,
    required: true,
    doc: "Current auth scope containing the user."

  def my_stats(assigns) do
    ~H"""
    <%= if @my_stats do %>
      <div class="p-4 rounded-box border border-primary/30 bg-primary/5 flex items-center gap-3">
        <div class="w-9 h-9 rounded-full overflow-hidden bg-base-300 shrink-0">
          <img src={@current_scope.user.profile_image} class="w-full h-full object-cover" />
        </div>
        <div class="flex-1 min-w-0">
          <p class="text-sm font-medium text-base-content truncate">
            {@current_scope.user.full_name}
            <span class="text-xs text-base-content/40 font-normal">(you)</span>
          </p>
          <p class="text-xs text-base-content/50">
            Rank #{@my_stats.rank}
          </p>
        </div>
        <div class="flex gap-3 text-center text-xs font-mono shrink-0">
          <div>
            <p class="text-success font-bold text-base">{@my_stats.wins}</p>
            <p class="text-base-content/40">W</p>
          </div>
          <div>
            <p class="text-error font-bold text-base">{@my_stats.losses}</p>
            <p class="text-base-content/40">L</p>
          </div>
          <div>
            <p class="text-base-content/60 font-bold text-base">{@my_stats.draws}</p>
            <p class="text-base-content/40">D</p>
          </div>
        </div>
      </div>
    <% end %>
    """
  end
end
