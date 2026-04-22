defmodule ChessWeb.Leaderboard.EmptyState do
  @moduledoc """
  Provides a reusable UI component for displaying an empty leaderboard state.

  This component is shown when there are no players to display in the leaderboard.
  It communicates to the user that no data is available yet and encourages engagement.
  """

  use ChessWeb, :html

  @doc """
  Renders the empty state for the leaderboard.

  Displays a simple message and icon indicating that no players are currently
  available. Intended to be used when the leaderboard dataset is empty.

  ## Examples

      <.empty_state />

  """

  use ChessWeb, :html

  attr :class, :string, default: nil, doc: "Optional additional CSS classes for the container."

  def empty_state(assigns) do
    ~H"""
    <div class="border border-base-300 rounded-box p-12 flex flex-col items-center gap-3 text-center">
      <.icon name="hero-trophy" class="size-10 text-base-content/20" />
      <p class="text-base-content/50 text-sm">
        No players yet. Play some games to appear here!
      </p>
    </div>
    """
  end
end
