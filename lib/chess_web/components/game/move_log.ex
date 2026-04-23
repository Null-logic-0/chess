defmodule ChessWeb.Game.MoveLog do
  @moduledoc """
  Renders a live-updating move history for a chess game.

  This component displays moves in a structured, chess-friendly format
  (move number + white move + black move). Moves are grouped into pairs
  to reflect standard notation and improve readability.

  ## Responsibilities

    * Present moves in numbered pairs (e.g. `1. e4 e5`)
    * Highlight the most recent move for quick visual scanning
    * Handle empty states gracefully
    * Provide a scrollable container for long games

  ## Expected assigns

    * `:game` — map or struct containing:
      * `:moves` — list of moves in chronological order (e.g. `["e4", "e5", "Nf3"]`)

  ## Example

      <.move_log game={@game} />

  ## Notes

  Moves are grouped using `Enum.chunk_every/2`, which assumes a flat list of
  alternating white/black moves. If the underlying representation changes
  (e.g. structured moves with metadata), this component should be updated
  accordingly.

  The "Live" indicator is purely visual and does not reflect connection state.
  """
  use ChessWeb, :html

  @doc """
  Renders the move history table.

  Moves are displayed in rows of:
    * move number
    * white move
    * black move

  The latest move (if it is a black move completing the pair) is visually highlighted.

  ## Assigns

    * `:game` — required, must include a `:moves` list

  ## Examples

      <.move_log game={%{moves: ["e4", "e5", "Nf3"]}} />
      # =>
      # 1. e4 e5
      # 2. Nf3

      <.move_log game={%{moves: []}} />
      # => renders "No moves yet"
  """
  def move_log(assigns) do
    ~H"""
    <div class="border border-base-300 rounded-box overflow-hidden bg-base-100">
      <div class="flex items-center justify-between px-4 py-2 border-b border-base-300 text-xs font-medium text-base-content/40 uppercase tracking-wider bg-base-200">
        <span>Move history</span>
        <span class="flex items-center gap-1.5">
          <span class="w-2 h-2 rounded-full bg-success animate-pulse"></span> Live
        </span>
      </div>
      <div class="grid grid-cols-[28px_1fr_1fr] font-mono text-xs max-h-40 overflow-y-auto">
        <%= for {pair, index} <- Enum.chunk_every(@game.moves, 2) |> Enum.with_index(1) do %>
          <div class="px-2 py-1 text-base-content/40 border-r border-base-300">{index}.</div>
          <div class="px-2 py-1 text-base-content">{Enum.at(pair, 0)}</div>
          <div class={[
            "px-2 py-1",
            length(@game.moves) == index * 2 && "bg-primary/10 text-primary font-medium"
          ]}>
            {Enum.at(pair, 1, "")}
          </div>
        <% end %>
        <%= if @game.moves == [] do %>
          <div class="col-span-3 px-3 py-4 text-center text-base-content/30 text-xs">
            No moves yet
          </div>
        <% end %>
      </div>
    </div>
    """
  end
end
