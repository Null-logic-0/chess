defmodule ChessWeb.BoardComponent do
  @moduledoc """
  Renders an interactive chess board component.

  This component is responsible for:
    * Rendering a chess position from a FEN string
    * Displaying pieces using image assets
    * Highlighting selected squares and legal move hints
    * Supporting board flipping (for black/white perspective)

  It is designed for use inside LiveView-based chess gameplay.
  """
  use ChessWeb, :html

  @files ~w(a b c d e f g h)
  @ranks ~w(8 7 6 5 4 3 2 1)

  @pieces %{
    "K" => "/images/king_white.png",
    "Q" => "/images/queen_white.png",
    "R" => "/images/rook_white.png",
    "B" => "/images/bishop_white.png",
    "N" => "/images/knight_white.png",
    "P" => "/images/pawn_white.png",
    "k" => "/images/king_black.png",
    "q" => "/images/queen_black.png",
    "r" => "/images/rook_black.png",
    "b" => "/images/bishop_black.png",
    "n" => "/images/knight_black.png",
    "p" => "/images/pawn_black.png"
  }

  @doc """
  Renders a chess board based on a FEN string.

  Supports:
    * Piece rendering
    * Square selection highlighting
    * Move hint visualization
    * Board orientation flipping

  ## Attributes

    * `:fen` - FEN string representing the board state
    * `:selected` - Currently selected square (e.g. "e4")
    * `:hints` - List of highlighted squares (legal moves / suggestions)
    * `:flipped` - Whether the board is flipped (black perspective)

  ## Examples

      <.board
        fen="rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR"
        selected="e2"
        hints={["e3", "e4"]}
        flipped={false}
      />

  """
  attr :fen, :string, required: true
  attr :selected, :string, default: nil
  attr :hints, :list, default: []
  attr :flipped, :boolean, default: false

  def board(assigns) do
    assigns =
      assigns
      |> assign(:board_map, fen_to_board(assigns.fen))
      |> assign(:pieces, @pieces)

    ~H"""
    <div class="select-none w-full">
      <div
        class="grid grid-cols-8 w-full rounded-box overflow-hidden border border-base-300 shadow-xl"
        style="aspect-ratio: 1 / 1;"
      >
        <%= for rank <- display_ranks(@flipped), file <- display_files(@flipped) do %>
          <% square = file <> rank %>
          <% piece = @board_map[square] %>
          <div
            phx-click="square_click"
            phx-value-square={square}
            style="aspect-ratio: 1 / 1;"
            class={[
              "relative flex items-center justify-center cursor-pointer transition-colors",
              square_bg(file, rank),
              @selected == square && "!bg-yellow-400/80",
              square in @hints && "!bg-green-400/50"
            ]}
          >
            <%= if piece do %>
              <img
                src={@pieces[piece]}
                class="absolute inset-[8%] w-[84%] h-[84%] object-contain pointer-events-none drop-shadow"
                draggable="false"
              />
            <% end %>
            <%= if square in @hints and is_nil(piece) do %>
              <span class="absolute w-[34%] h-[34%] rounded-full bg-black/25 pointer-events-none" />
            <% end %>
            <%= if square in @hints and not is_nil(piece) do %>
              <span class="absolute inset-0 ring-[6px] ring-inset ring-green-500/70 pointer-events-none" />
            <% end %>
          </div>
        <% end %>
      </div>
    </div>
    """
  end

  @doc """
  Converts a FEN string into a map of board squares to piece symbols.

  Returns a map like:
      %{"e4" => "P", "e5" => "k"}
  """
  def fen_to_board(fen) do
    fen
    |> String.split(" ")
    |> hd()
    |> String.split("/")
    |> Enum.with_index()
    |> Enum.flat_map(fn {row, rank_i} ->
      rank = Integer.to_string(8 - rank_i)

      row
      |> expand_fen_row()
      |> Enum.with_index()
      |> Enum.map(fn {piece, file_i} ->
        {Enum.at(@files, file_i) <> rank, piece}
      end)
    end)
    |> Enum.reject(fn {_, v} -> is_nil(v) end)
    |> Map.new()
  end

  defp expand_fen_row(row) do
    row
    |> String.graphemes()
    |> Enum.flat_map(fn
      n when n in ~w(1 2 3 4 5 6 7 8) -> List.duplicate(nil, String.to_integer(n))
      piece -> [piece]
    end)
  end

  defp display_ranks(false), do: @ranks
  defp display_ranks(true), do: Enum.reverse(@ranks)

  defp display_files(false), do: @files
  defp display_files(true), do: Enum.reverse(@files)

  defp square_bg(file, rank) do
    file_i = Enum.find_index(@files, &(&1 == file))
    rank_i = Enum.find_index(@ranks, &(&1 == rank))
    if rem(file_i + rank_i, 2) == 0, do: "bg-[#f0d9b5]", else: "bg-[#b58863]"
  end
end
