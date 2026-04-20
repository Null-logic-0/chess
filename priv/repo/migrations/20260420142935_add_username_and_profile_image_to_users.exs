defmodule Chess.Repo.Migrations.AddUsernameAndProfileImageToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :username, :string
      add :profile_image, :string
    end

    create unique_index(:users, [:username])
  end
end
