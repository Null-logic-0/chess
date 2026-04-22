defmodule Chess.Repo.Migrations.AddStatsToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :wins, :integer, default: 0, null: false
      add :losses, :integer, default: 0, null: false
      add :draws, :integer, default: 0, null: false
    end
  end
end
