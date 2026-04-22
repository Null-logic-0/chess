defmodule Chess.Repo.Migrations.AddUsernameAndProfileImageToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :full_name, :string
      add :profile_image, :string
    end
  end
end
