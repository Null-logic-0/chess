defmodule ChessWeb.HomeLive do
  @moduledoc """
  Home page LiveView for ChessHub.
  """
  use ChessWeb, :live_view
  import ChessWeb.HeroSection

  on_mount {ChessWeb.UserAuth, :mount_current_scope}

  def render(assigns) do
    ~H"""
    <Layouts.app flash={@flash} current_scope={@current_scope}>
      <.hero_section current_scope={@current_scope} />
    </Layouts.app>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, socket}
  end
end
