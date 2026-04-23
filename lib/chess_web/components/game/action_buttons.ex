defmodule ChessWeb.Game.ActionButtons do
  @moduledoc """
  Renders the primary action controls for an active chess game.

  This component groups all user-initiated game actions such as:
    * UI manipulation (e.g. flipping the board)
    * Game state mutations (resigning, offering a draw)
    * Navigation back to the lobby

  It is designed to be state-aware and only enables destructive or game-affecting
  actions when the game is actively in progress.

  ## Responsibilities

    * Provide consistent UI for in-game actions
    * Disable game-affecting actions when the game is not `"playing"`
    * Delegate actual behavior to LiveView events
    * Keep UI feedback (hover/disabled states) consistent with game state

  ## Expected assigns

    * `:game` — map/struct with at least:
      * `:status` — current game status (`"playing"` or terminal state)

  ## Events triggered

    * `"flip_board"` — toggles board orientation (UI-only)
    * `"resign"` — resigns the current game (requires confirmation)
    * `"offer_draw"` — initiates a draw offer flow

  ## Example

      <.action_buttons game={@game} />

  ## Notes

  * Resign action includes a browser-level confirmation dialog (`phx-confirm`)
  * Draw and resign actions are disabled outside active gameplay
  * Navigation is handled via LiveView patching (`navigate`), not full page reload

  Future improvements may include:
    * Replacing string-based status checks with atoms/enums
    * Extracting action availability logic into a helper (e.g. `GameActions.enabled?/2`)
    * Adding optimistic UI feedback for draw offers
  """
  use ChessWeb, :html

  @doc """
  Renders in-game action buttons for board interaction and game control.

  Buttons include:
    * Flip board (always enabled)
    * Resign (disabled when game is not active)
    * Offer draw (disabled when game is not active)
    * Exit to lobby (navigation link)

  ## Assigns

    * `:game` — required, must include `:status`

  ## Examples

      <.action_buttons game={%{status: "playing"}} />

      <.action_buttons game={%{status: "checkmate"}} />
      # => only Flip + Exit enabled, others disabled
  """
  def action_buttons(assigns) do
    ~H"""
    <div class="grid grid-cols-3 gap-2">
      <button
        phx-click="flip_board"
        class="flex items-center justify-center gap-1.5 px-3 py-2 cursor-pointer text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-base-200 transition-colors"
      >
        <.icon name="hero-arrow-uturn-down" class="size-4" /> Flip
      </button>
      <button
        phx-click="resign"
        phx-confirm="Are you sure you want to resign?"
        disabled={@game.status != "playing"}
        class="flex items-center justify-center gap-1.5 px-2 py-2 cursor-pointer text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-error/10 hover:border-error hover:text-error transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
      >
        <.icon name="hero-flag" class="size-4" /> Resign
      </button>
      <button
        phx-click="offer_draw"
        disabled={@game.status != "playing"}
        class="flex items-center justify-center gap-1.5 px-2 py-2 cursor-pointer text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-warning/10 hover:border-warning hover:text-warning transition-colors disabled:opacity-40 disabled:cursor-not-allowed"
      >
        <.icon name="hero-equals" class="size-4" /> Draw
      </button>

      <.link
        navigate={~p"/"}
        class="col-span-3 flex items-center justify-center gap-1.5 px-3 py-2 cursor-pointer text-sm border border-base-300 rounded-field bg-base-100 text-base-content hover:bg-base-200 transition-colors"
      >
        <.icon name="hero-arrow-left" class="size-4" /> Exit to Lobby
      </.link>
    </div>
    """
  end
end
