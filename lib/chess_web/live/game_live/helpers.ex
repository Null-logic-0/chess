defmodule ChessWeb.GameLive.Helpers do
  @moduledoc """
  UI-facing helper functions for Chess LiveView components.

  This module contains presentation-level logic used by LiveView templates
  to derive display values from game state, user identity, and FEN data.

  ## Responsibilities

    * Resolve player perspective (my color vs opponent)
    * Format time values for UI display
    * Compute lightweight derived view state (labels, initials)
    * Provide minimal chess-board UI utilities

  ## Non-responsibilities

    * This module does NOT enforce game rules
    * It does NOT mutate or persist state
    * It should NOT contain business logic beyond presentation needs

  Think of this as a "view-model helper layer" for LiveView templates.
  """

  alias Chess.Accounts

  @doc """
  Returns the perspective color (`:white` or `:black`) for the current user.

  Defaults to `:white` if the user is not a participant in the game.

  ## Examples

      my_color(game, user_id)
      #=> :white | :black
  """
  def my_color(game, my_id) do
    cond do
      game.white_id == my_id -> :white
      game.black_id == my_id -> :black
      true -> :white
    end
  end

  @doc """
  Loads the opponent user record for the current player.

  Returns `nil` if:
    * user is not part of the game
    * opponent slot is empty

  ## Examples

      load_opponent(game, user_id)
      #=> %User{} | nil
  """
  def load_opponent(game, my_id) do
    opponent_id =
      cond do
        game.white_id == my_id -> game.black_id
        game.black_id == my_id -> game.white_id
        true -> nil
      end

    if opponent_id, do: Accounts.get_user(opponent_id), else: nil
  end

  @doc """
  Returns the remaining time (in milliseconds) for the current user.

  ## Examples

      my_time_ms(:white, white_ms, black_ms)
      #=> integer milliseconds
  """
  def my_time_ms(:white, white_ms, _), do: white_ms
  def my_time_ms(:black, _, black_ms), do: black_ms

  @doc """
  Returns the opponent's remaining time (in milliseconds).

  ## Examples

      opponent_time_ms(:white, white_ms, black_ms)
      #=> black_ms
  """
  def opponent_time_ms(:white, _, black_ms), do: black_ms
  def opponent_time_ms(:black, white_ms, _), do: white_ms

  @doc """
  Formats a millisecond duration into `MM:SS` string format.

  Negative or zero values are clamped to `"00:00"`.

  ## Examples

      format_time(125_000)
      #=> "02:05"
  """
  def format_time(ms) when ms <= 0, do: "00:00"

  def format_time(ms) do
    total_seconds = div(ms, 1000)
    minutes = div(total_seconds, 60)
    seconds = rem(total_seconds, 60)
    :io_lib.format("~2..0B:~2..0B", [minutes, seconds]) |> to_string()
  end

  @doc """
  Returns a human-readable label for the player's color.
  """
  def my_color_label(:white), do: "White"
  def my_color_label(:black), do: "Black"

  @doc """
  Returns the opponent's color label relative to the current player.
  """
  def opponent_color_label(:white), do: "Black"
  def opponent_color_label(:black), do: "White"

  @doc """
  Generates display initials from a user's full name.

  Takes the first two uppercase characters.

  ## Examples

      user_initials(%{full_name: "John Doe"})
      #=> "JO"
  """
  def user_initials(%{full_name: full_name}),
    do: full_name |> String.upcase() |> String.slice(0, 2)

  @doc """
  Returns initials for the opponent user or fallback `"?"` if unknown.
  """
  def opponent_initials(nil), do: "?"

  def opponent_initials(%{full_name: full_name}),
    do: full_name |> String.upcase() |> String.slice(0, 2)

  @doc """
  Checks whether a given square contains a piece belonging to the current player.

  This is a UI helper used for board highlighting.

  ## Parameters

    * `fen` - current board FEN string
    * `square` - board coordinate (e.g. "e4")
    * `my_color` - `:white` or `:black`

  ## Notes

  This function depends on `ChessWeb.BoardComponent.fen_to_board/1`
  which returns a square-indexed map of pieces.

  It is strictly presentation logic and should NOT be used for validation
  of legal moves.
  """
  def my_piece?(fen, square, my_color) do
    piece = ChessWeb.BoardComponent.fen_to_board(fen)[square]

    case my_color do
      :white -> piece && piece == String.upcase(piece) && piece != String.downcase(piece)
      :black -> piece && piece == String.downcase(piece) && piece != String.upcase(piece)
    end
  end
end
