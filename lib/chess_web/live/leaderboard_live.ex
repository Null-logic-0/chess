defmodule ChessWeb.LeaderboardLive do
  use ChessWeb, :live_view
  alias Chess.Accounts

  @per_page 20

  def mount(_params, _session, socket) do
    my_id = socket.assigns.current_scope.user.id

    socket =
      socket
      |> assign(:page, 1)
      |> assign(:per_page, @per_page)
      |> assign(my_id: my_id)
      |> assign(:end_of_list, false)
      |> assign(:loading, true)
      |> assign(:error, nil)
      |> assign(:my_stats, nil)
      |> assign(:players, [])

    send(self(), :load_data)

    {:ok, socket}
  end

  def handle_info(:load_data, socket) do
    my_id = socket.assigns.current_scope.user.id

    try do
      players = Accounts.get_leaderboard(socket.assigns.page, socket.assigns.per_page)
      my_stats = Accounts.get_user_stats(my_id)

      {:noreply,
       socket
       |> assign(:players, players)
       |> assign(:my_stats, my_stats)
       |> assign(:end_of_list, length(players) < socket.assigns.per_page)
       |> assign(:loading, false)}
    rescue
      _ ->
        {:noreply,
         socket |> assign(:loading, false) |> assign(:error, "Failed to load leaderboard.")}
    end
  end

  def handle_event("load_more", _, %{assigns: %{end_of_list: true}} = socket) do
    {:noreply, socket}
  end

  def handle_event("load_more", _, socket) do
    next_page = socket.assigns.page + 1

    try do
      new_players = Accounts.get_leaderboard(next_page, socket.assigns.per_page)

      {:noreply,
       socket
       |> assign(:page, next_page)
       |> update(:players, &(&1 ++ new_players))
       |> assign(:end_of_list, length(new_players) < socket.assigns.per_page)}
    rescue
      _ ->
        {:noreply, put_flash(socket, :error, "Failed to load more players.")}
    end
  end

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-xl mx-auto flex flex-col gap-4 pb-8">
        <h1 class="text-xl font-bold text-base-content">Leaderboard</h1>

        <%!-- My stats card --%>
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

        <%!-- Error state --%>
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

        <%!-- Loading state --%>
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

        <%!-- Loaded state --%>
        <%= if not @loading and is_nil(@error) do %>
          <%= if @players == [] do %>
            <%!-- Empty state --%>
            <div class="border border-base-300 rounded-box p-12 flex flex-col items-center gap-3 text-center">
              <.icon name="hero-trophy" class="size-10 text-base-content/20" />
              <p class="text-base-content/50 text-sm">
                No players yet. Play some games to appear here!
              </p>
            </div>
          <% else %>
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
                      if(player.id == @current_scope.user.id,
                        do: "bg-primary/5",
                        else: "hover:bg-base-200"
                      )
                    ]}>
                      <td class="px-4 py-2 font-mono">
                        <%= cond do %>
                          <% i == 1 -> %>
                            <span class="text-yellow-500">🥇</span>
                          <% i == 2 -> %>
                            <span class="text-gray-400">🥈</span>
                          <% i == 3 -> %>
                            <span class="text-amber-600">🥉</span>
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
                            if(player.id == @current_scope.user.id,
                              do: "text-primary",
                              else: "text-base-content"
                            )
                          ]}>
                            {player.full_name}
                            <%= if player.id == @current_scope.user.id do %>
                              <span class="text-xs text-base-content/40 font-normal">(you)</span>
                            <% end %>
                          </span>
                        </div>
                      </td>
                      <td class="px-4 py-2 text-center text-success font-mono">{player.wins}</td>
                      <td class="px-4 py-2 text-center text-error font-mono">{player.losses}</td>
                      <td class="px-4 py-2 text-center text-base-content/50 font-mono">
                        {player.draws}
                      </td>
                    </tr>
                  <% end %>
                </tbody>
              </table>
            </div>

            <%!-- Load more / end of list --%>
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
          <% end %>
        <% end %>
      </div>
    </Layouts.app>
    """
  end
end
