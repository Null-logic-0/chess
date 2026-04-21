defmodule Chess.Messages.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :content, :string

    belongs_to :game, Chess.Games.Game
    belongs_to :user, Chess.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs, user_scope) do
    message
    |> cast(attrs, [:content, :game_id, :user_id])
    |> validate_required([:content, :game_id, :user_id])
    |> put_assoc(:user, user_scope.user)
  end
end
