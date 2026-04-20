defmodule ChessWeb.HeroSection do
  use ChessWeb, :html

  @doc """
  Renders the main hero section for the ChessHub landing page.

  Displays:
  - Title and tagline
  - Description text
  - A primary action button

  Behavior:
  - If `current_scope` is present (user is authenticated), shows a **Create Meeting** button
  - Otherwise, shows a **Log in** button that navigates to the login page

  ## Assigns

    * `:current_scope` - The current user/session scope (nil if unauthenticated)

  """
  attr :current_scope, :any,
    default: nil,
    doc: "Current authenticated scope (e.g., user or session)"

  def hero_section(assigns) do
    ~H"""
    <div class="max-w-sm mx-auto space-y-6">
      <div class=" w-full text-center space-y-4">
        <h1 class="text-3xl font-bold text-primary">Welcome to ChessHub</h1>
        <p class="text-5xl font-medium text-base-content leading-normal">
          Play Chess Online with your Firends and Family!
        </p>
      </div>

      <div class="flex flex-col gap-4 ">
        <%= if @current_scope do %>
          <.button
            phx-click="play"
            class="btn btn-primary py-6 flex items-center justify-center"
          >
            <span class="flex items-center gap-2 text-xl">
              <.icon name="hero-puzzle-piece" class="size-8" /> Play
            </span>
          </.button>
        <% else %>
          <.button
            phx-click={JS.navigate(~p"/users/log-in")}
            class="btn btn-primary py-6 flex items-center justify-center"
          >
            <span class="flex items-center text-xl gap-2">
              <.icon name="hero-arrow-left-end-on-rectangle" class="size-8" /> Log in
            </span>
          </.button>
        <% end %>
      </div>
    </div>
    """
  end
end
