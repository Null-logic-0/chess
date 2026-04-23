defmodule ChessWeb.GameLive.HelpersTest do
  use ExUnit.Case, async: true

  alias ChessWeb.GameLive.Helpers

  # A minimal game struct for testing
  defp game(white_id: white_id, black_id: black_id) do
    %{white_id: white_id, black_id: black_id}
  end

  describe "my_color/2" do
    test "returns :white when user is white" do
      assert Helpers.my_color(game(white_id: 1, black_id: 2), 1) == :white
    end

    test "returns :black when user is black" do
      assert Helpers.my_color(game(white_id: 1, black_id: 2), 2) == :black
    end

    test "defaults to :white for spectators" do
      assert Helpers.my_color(game(white_id: 1, black_id: 2), 99) == :white
    end
  end

  describe "load_opponent/2" do
    test "returns nil when user is not in game" do
      assert Helpers.load_opponent(game(white_id: 1, black_id: 2), 99) == nil
    end

    test "returns nil when opponent slot is nil (white is me, black is empty)" do
      assert Helpers.load_opponent(game(white_id: 1, black_id: nil), 1) == nil
    end

    test "returns nil when opponent slot is nil (black is me, white is empty)" do
      assert Helpers.load_opponent(game(white_id: nil, black_id: 2), 2) == nil
    end
  end

  describe "my_time_ms/3" do
    test "returns white_ms for white player" do
      assert Helpers.my_time_ms(:white, 60_000, 30_000) == 60_000
    end

    test "returns black_ms for black player" do
      assert Helpers.my_time_ms(:black, 60_000, 30_000) == 30_000
    end
  end

  describe "opponent_time_ms/3" do
    test "returns black_ms when I am white" do
      assert Helpers.opponent_time_ms(:white, 60_000, 30_000) == 30_000
    end

    test "returns white_ms when I am black" do
      assert Helpers.opponent_time_ms(:black, 60_000, 30_000) == 60_000
    end
  end

  describe "format_time/1" do
    test "formats positive milliseconds into MM:SS" do
      assert Helpers.format_time(125_000) == "02:05"
    end

    test "formats zero as 00:00" do
      assert Helpers.format_time(0) == "00:00"
    end

    test "formats negative values as 00:00" do
      assert Helpers.format_time(-5000) == "00:00"
    end

    test "formats exactly one minute" do
      assert Helpers.format_time(60_000) == "01:00"
    end

    test "formats sub-minute time" do
      assert Helpers.format_time(9_000) == "00:09"
    end

    test "formats large values" do
      assert Helpers.format_time(600_000) == "10:00"
    end
  end

  describe "my_color_label/1" do
    test "returns 'White' for :white" do
      assert Helpers.my_color_label(:white) == "White"
    end

    test "returns 'Black' for :black" do
      assert Helpers.my_color_label(:black) == "Black"
    end
  end

  describe "opponent_color_label/1" do
    test "returns 'Black' when I am :white" do
      assert Helpers.opponent_color_label(:white) == "Black"
    end

    test "returns 'White' when I am :black" do
      assert Helpers.opponent_color_label(:black) == "White"
    end
  end

  describe "user_initials/1" do
    test "returns first two uppercase chars of full name" do
      assert Helpers.user_initials(%{full_name: "John Doe"}) == "JO"
    end

    test "handles single word names" do
      assert Helpers.user_initials(%{full_name: "Alice"}) == "AL"
    end

    test "handles short names" do
      assert Helpers.user_initials(%{full_name: "Al"}) == "AL"
    end

    test "handles single character name" do
      assert Helpers.user_initials(%{full_name: "A"}) == "A"
    end
  end

  describe "opponent_initials/1" do
    test "returns '?' for nil opponent" do
      assert Helpers.opponent_initials(nil) == "?"
    end

    test "returns initials for a real opponent" do
      assert Helpers.opponent_initials(%{full_name: "Bob Smith"}) == "BO"
    end
  end

  describe "my_piece?/3" do
    # Starting position FEN
    @start_fen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

    test "returns true for white piece on white's square" do
      assert Helpers.my_piece?(@start_fen, "e2", :white) == true
    end

    test "returns true for black piece on black's square" do
      assert Helpers.my_piece?(@start_fen, "e7", :black) == true
    end

    test "returns false for white piece when checking as black" do
      assert Helpers.my_piece?(@start_fen, "e2", :black) == false
    end

    test "returns false for empty square" do
      refute Helpers.my_piece?(@start_fen, "e4", :white)
    end

    test "returns false for black piece when checking as white" do
      refute Helpers.my_piece?(@start_fen, "e4", :white)
    end
  end
end
