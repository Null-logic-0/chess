defmodule Chess.ChessEngine do
  def apply_move(fen, uci_move) do
    with_game(fen, fn pid ->
      case :binbo.move(pid, uci_move) do
        {:ok, _status} ->
          {:ok, new_fen} = :binbo.get_fen(pid)
          {:ok, new_fen}

        {:error, reason} ->
          {:error, reason}
      end
    end)
  end

  def legal_moves_from(fen, square) do
    with_game(fen, fn pid ->
      {:ok, moves} = :binbo.all_legal_moves(pid, :bin)

      destinations =
        moves
        |> Enum.filter(fn {from, _to} -> from == square end)
        |> Enum.map(fn {_from, to} -> to end)

      {:ok, destinations}
    end)
    |> case do
      {:ok, destinations} -> destinations
      _ -> []
    end
  end

  def game_status(fen) do
    with_game(fen, fn pid ->
      case :binbo.game_status(pid) do
        {:ok, :continue} -> {:ok, :playing}
        {:ok, :checkmate} -> {:ok, :checkmate}
        {:ok, {:draw, reason}} -> {:ok, {:draw, reason}}
        {:error, reason} -> {:error, reason}
      end
    end)
    |> case do
      {:ok, status} -> status
      _ -> :playing
    end
  end

  def whose_turn(fen) do
    fen
    |> String.split(" ")
    |> Enum.at(1)
    |> case do
      "w" -> :white
      "b" -> :black
    end
  end

  defp with_game(fen, fun) do
    {:ok, pid} = :binbo.new_server()
    :binbo.new_game(pid, fen)
    result = fun.(pid)
    :binbo.stop_server(pid)
    result
  end
end
