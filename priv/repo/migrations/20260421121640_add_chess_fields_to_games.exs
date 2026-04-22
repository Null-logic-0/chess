defmodule Chess.Repo.Migrations.AddChessFieldsToGames do
  use Ecto.Migration

  def change do
    alter table(:games) do
      add :fen, :string, default: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

      add :moves, {:array, :string}, default: []
      add :status, :string, default: "playing"
      add :white_id, :integer
      add :black_id, :integer
      add :white_time_ms, :integer, default: 300_000
      add :black_time_ms, :integer, default: 300_000
    end
  end
end
