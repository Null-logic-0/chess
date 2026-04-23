defmodule ChessWeb.Game.StatusBanner do
  @moduledoc """
  Renders a visual status banner for a chess game when the game is no longer in progress.

  This component is responsible for presenting terminal game states (e.g. checkmate,
  resignation, timeout, or draw) in a consistent and user-friendly format.

  ## Responsibilities

    * Hide itself while the game is in the `"playing"` state
    * Translate internal game status values into human-readable labels
    * Provide a consistent UI style for all terminal states

  ## Expected assigns

    * `:game` — a map or struct containing at least:
      * `:status` — a string representing the current game state

  ## Example

      <.status_banner game={@game} />

  ## Notes

  The mapping of status → label is intentionally kept private to avoid leaking
  domain-specific strings into templates. If new game states are introduced,
  they should be added to `status_label/1`.

  Unknown statuses will render no banner.
  """

  use ChessWeb, :html

  @doc """
  Renders a banner displaying the final state of the game.

  The banner is only shown when the game is not in the `"playing"` state.
  It uses `status_label/1` to convert the internal status into a user-facing message.

  ## Assigns

    * `:game` — required, must include a `:status` field

  ## Examples

      <.status_banner game={%{status: "checkmate"}} />
      # => renders "Checkmate!"

      <.status_banner game={%{status: "playing"}} />
      # => renders nothing
  """
  def status_banner(assigns) do
    ~H"""
    <%= if @game.status != "playing" do %>
      <div class="p-3 rounded-box bg-warning/10 border border-warning text-warning text-sm text-center font-medium">
        {status_label(@game.status)}
      </div>
    <% end %>
    """
  end

  @doc false
  defp status_label("checkmate"), do: "Checkmate!"
  defp status_label("draw"), do: "Draw agreed"
  defp status_label("timeout_white_wins"), do: "White wins on time!"
  defp status_label("timeout_black_wins"), do: "Black wins on time!"
  defp status_label("resigned_white_wins"), do: "White wins — Black resigned"
  defp status_label("resigned_black_wins"), do: "Black wins — White resigned"
  defp status_label(_), do: ""
end
