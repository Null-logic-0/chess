defmodule ChessWeb.Leaderboard.ErrorState do
  @moduledoc """
  Provides a reusable UI component for displaying error states in the leaderboard.

  This component is responsible for rendering an error message along with a retry
  action when data fetching or processing fails.
  """
  use ChessWeb, :html

  @doc """
  Renders an error state message with an optional retry action.

  The component is only rendered when an error message is present. It displays
  a styled error container, an icon, the error message, and a "Try again" button
  that triggers a retry event.

  ## Attributes

    * `:error` - A string containing the error message to display. If `nil` or
      falsy, the component renders nothing.

  ## Examples

      <.error_state error="Failed to load leaderboard." />

  """
  attr :error, :string,
    default: nil,
    doc: "Error message to display. If nil, nothing is rendered."

  def error_state(assigns) do
    ~H"""
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
    """
  end
end
