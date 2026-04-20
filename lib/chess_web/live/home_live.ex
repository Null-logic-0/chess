defmodule ChessWeb.HomeLive do
  @moduledoc """
  Home page LiveView for ChessHub.
  """
  use ChessWeb, :live_view
  import ChessWeb.HeroSection
  alias Chess.Games

  on_mount {ChessWeb.UserAuth, :mount_current_scope}

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.hero_section current_scope={@current_scope} />
    </Layouts.app>
    """
  end

  @doc """
  Initializes the home page.

  Currently no state is required; relies on authenticated scope.
  """
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @doc """
  Creates a new room for the current user and redirects into it.
  """
  def handle_event("play", _, socket) do
    current_user = socket.assigns[:current_scope]

    {:ok, game} =
      Games.create_game(current_user)

    {:noreply, push_navigate(socket, to: "/#{game.slug}")}
  end
end
