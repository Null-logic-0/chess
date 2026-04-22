defmodule ChessWeb.LeaderboardLive do
  use ChessWeb, :live_view

  import ChessWeb.Leaderboard.MyStats
  import ChessWeb.Leaderboard.ErrorState
  import ChessWeb.Leaderboard.LoadingState
  import ChessWeb.Leaderboard.EmptyState
  import ChessWeb.Leaderboard.LeaderboardTable
  import ChessWeb.Leaderboard.LoadMore
  alias Chess.Accounts

  @per_page 20

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="max-w-xl mx-auto flex flex-col gap-4 pb-8">
        <h1 class="text-3xl font-bold text-base-content">{@page_title}</h1>

        <.my_stats my_stats={@my_stats} current_scope={@current_scope} />

        <.error_state error={@error} />

        <.loading_state loading={@loading} />

        <%= if not @loading and is_nil(@error) do %>
          <%= if @players == [] do %>
            <.empty_state />
          <% else %>
            <.leaderboard_table players={@players} current_user={@current_scope.user} />
            <.load_more end_of_list={@end_of_list} />
          <% end %>
        <% end %>
      </div>
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    my_id = socket.assigns.current_scope.user.id

    socket =
      socket
      |> assign(:page, 1)
      |> assign(:per_page, @per_page)
      |> assign(page_title: "Leaderboard")
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
end
