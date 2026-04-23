defmodule ChessWeb.Game.ShareLink do
  @moduledoc """
  Renders a shareable game link while waiting for an opponent to join.

  This component is displayed only when the game is in a joinable state
  (i.e. still `"playing"`) and no opponent has connected yet.

  It provides a simple UX for inviting another player by:
    * Showing the game URL
    * Allowing one-click copy via a client-side hook

  ## Responsibilities

    * Conditionally render based on game state and opponent presence
    * Display a shareable, read-only game URL
    * Integrate with a JS hook for clipboard interaction
    * Provide visual feedback when the link is copied

  ## Expected assigns

    * `:game` — map/struct with at least:
      * `:status` — current game status
    * `:opponent` — `nil` when no opponent has joined
    * `:game_url` — fully qualified URL to the game
    * `:copied` — boolean flag for UI feedback after copy action

  ## Example

      <.share_link
        game={@game}
        opponent={@opponent}
        game_url={@game_url}
        copied={@copied}
      />

  ## Notes

  The copy functionality relies on a Phoenix LiveView hook (`CopyToClipboard`).
  This component does not handle the copy logic itself—only the UI state.

  If the game state model evolves (e.g. introducing a `"waiting"` state),
  the rendering condition should be updated accordingly.
  """
  use ChessWeb, :html

  @doc """
  Renders a share link UI for inviting an opponent.

  The component is visible only when:
    * `@opponent` is `nil`
    * `@game.status == "playing"`

  ## Assigns

    * `:game` — required, must include a `:status`
    * `:opponent` — required, determines if an opponent has joined
    * `:game_url` — required, the link to share
    * `:copied` — required, controls button label feedback

  ## Examples

      <.share_link
        game={%{status: "playing"}}
        opponent={nil}
        game_url={"https://example.com/game/123"}
        copied={false}
      />
      # => renders share UI

      <.share_link
        game={%{status: "playing"}}
        opponent={%User{}}
        game_url={"..."}
        copied={false}
      />
      # => renders nothing
  """
  def share_link(assigns) do
    ~H"""
    <%= if is_nil(@opponent) && @game.status == "playing" do %>
      <div class="p-3 rounded-box bg-info/10 border border-info text-info text-sm">
        <p class="text-center font-medium mb-2">Waiting for opponent — share this link:</p>
        <div class="flex items-center gap-2">
          <input
            type="text"
            readonly
            value={@game_url}
            class="flex-1 text-xs font-mono bg-base-100 border border-info/40 rounded-field px-2 py-1.5 text-base-content outline-none"
          />
          <button
            id="copy-btn"
            phx-hook="CopyToClipboard"
            data-url={@game_url}
            class="shrink-0 px-3 py-1.5 text-xs border border-info rounded-field bg-info/10 text-info hover:bg-info/20 transition-colors cursor-pointer"
          >
            {if @copied, do: "Copied!", else: "Copy"}
          </button>
        </div>
      </div>
    <% end %>
    """
  end
end
