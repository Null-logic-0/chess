defmodule Chess.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  schema "games" do
    field :slug, :string
    belongs_to :user, Chess.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(game, attrs, user_scope) do
    game
    |> cast(attrs, [:slug])
    |> put_change(:slug, generate_slug())
    |> put_assoc(:user, user_scope.user)
  end

  defp generate_slug() do
    parts =
      for _ <- 1..3 do
        :crypto.strong_rand_bytes(2)
        |> Base.url_encode64(padding: false)
        |> binary_part(0, 3)
      end

    Enum.join(parts, "-")
  end
end
