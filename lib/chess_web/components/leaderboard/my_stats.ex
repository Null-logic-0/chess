defmodule ChessWeb.Leaderboard.MyStats do
  use ChessWeb, :html

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
