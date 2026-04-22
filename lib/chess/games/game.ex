defmodule Chess.Games.Game do
  use Ecto.Schema
  import Ecto.Changeset

  @starting_fen "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"

  schema "games" do
    field :slug, :string
    field :fen, :string, default: @starting_fen
    field :moves, {:array, :string}, default: []
    field :status, :string, default: "playing"
    field :white_id, :integer
    field :black_id, :integer
    field :white_time_ms, :integer, default: 300_000
    field :black_time_ms, :integer, default: 300_000

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

  def state_changeset(game, attrs) do
    game
    |> cast(attrs, [:fen, :moves, :status, :white_id, :black_id, :white_time_ms, :black_time_ms])
    |> validate_required([:fen, :status])
    |> validate_inclusion(:status, [
      "playing",
      "checkmate",
      "draw",
      "resigned_white_wins",
      "resigned_black_wins",
      "timeout_white_wins",
      "timeout_black_wins"
    ])
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
