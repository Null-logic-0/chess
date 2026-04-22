defmodule ChessWeb.LeaderboardLive do
  @moduledoc """
  LiveView responsible for rendering and managing the leaderboard page.

  This view displays a paginated list of top players along with the current
  user's personal statistics. It supports incremental loading ("load more")
  and handles multiple UI states including loading, error, and empty results.

  Data is fetched asynchronously after mount to avoid blocking the initial render.
  """
  use ChessWeb, :live_view

  import ChessWeb.Leaderboard.MyStats
  import ChessWeb.Leaderboard.ErrorState
  import ChessWeb.Leaderboard.LoadingState
  import ChessWeb.Leaderboard.EmptyState
  import ChessWeb.Leaderboard.LeaderboardTable
  import ChessWeb.Leaderboard.LoadMore
  alias Chess.Accounts

  @per_page 20

  @doc """
  Renders the leaderboard page.

  Displays:
    * Page title
    * Current user's statistics
    * Error or loading states when applicable
    * Leaderboard table with players
    * "Load more" control for pagination

  The UI adapts dynamically based on the current assigns:
    * `:loading` — shows loading state
    * `:error` — shows error message
    * `:players` — renders table or empty state
  """
  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <div class="flex flex-col gap-4 pb-8">
        <div class="flex items-center justify-between">
          <h1 class="text-3xl font-bold text-base-content">
            {@page_title}
          </h1>

          <button
            type="button"
            onclick="window.history.back()"
            class="btn btn-sm btn-ghost text-base-content/60 hover:text-base-content"
          >
            ← Go back
          </button>
        </div>
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

  @doc """
  Initializes the LiveView socket with default state.

  Sets up pagination, loading flags, and assigns the current user's ID.
  Triggers asynchronous data loading via `:load_data` message.

  ## Assigns initialized
    * `:page` — current page number (default: 1)
    * `:per_page` — number of players per page
    * `:players` — list of leaderboard players
    * `:my_stats` — current user's stats
    * `:loading` — loading indicator
    * `:error` — error message (if any)
    * `:end_of_list` — indicates if all data has been loaded
  """
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

  @doc """
  Handles asynchronous data loading.

  Fetches:
    * Leaderboard players for the current page
    * Current user's statistics

  Updates the socket with the fetched data and determines whether the
  end of the list has been reached.

  In case of failure, sets an error message and disables loading state.
  """
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

  @doc """
  Handles the "load_more" event when no more data is available.

  Returns the socket unchanged.
  """
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
