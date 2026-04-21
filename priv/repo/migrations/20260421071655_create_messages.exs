defmodule Chess.Repo.Migrations.CreateMessages do
  use Ecto.Migration

  def change do
    create table(:messages) do
      add :content, :text
      add :game_id, references(:games, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps(type: :utc_datetime)
    end

    create index(:messages, [:user_id])

    create index(:messages, [:game_id])
  end
end
