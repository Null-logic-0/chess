defmodule Chess.Games do
  @moduledoc """
  The Games context.
  """

  import Ecto.Query, warn: false
  alias Chess.Repo

  alias Chess.Games.Game
  alias Chess.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any game changes.

  The broadcasted messages match the pattern:

    * {:created, %Game{}}
    * {:updated, %Game{}}
    * {:deleted, %Game{}}

  """
  def subscribe_games(%Scope{} = scope) do
    key = scope.user.id

    Phoenix.PubSub.subscribe(Chess.PubSub, "user:#{key}:games")
  end

  defp broadcast_game(%Scope{} = scope, message) do
    key = scope.user.id

    Phoenix.PubSub.broadcast(Chess.PubSub, "user:#{key}:games", message)
  end

  @doc """
  Gets a single game.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game!(scope, 123)
      %Game{}

      iex> get_game!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_game!(%Scope{} = scope, id) do
    Repo.get_by!(Game, id: id, user_id: scope.user.id)
  end

  @doc """
  Gets a single game by slug.

  Raises `Ecto.NoResultsError` if the Game does not exist.

  ## Examples

      iex> get_game_by_slug!("slug")
      %Game{}

      iex> get_game_by_slug!("invalid-slug")
      ** (Ecto.NoResultsError)

  """
  def get_game_by_slug!(slug) do
    Game
    |> where([r], r.slug == ^slug)
    |> preload(:user)
    |> Repo.one()
  end

  @doc """
  Creates a game.

  ## Examples

      iex> create_game(scope, %{field: value})
      {:ok, %Game{}}

      iex> create_game(scope, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_game(%Scope{} = scope, attrs \\ %{}) do
    with {:ok, game = %Game{}} <-
           %Game{}
           |> Game.changeset(attrs, scope)
           |> Repo.insert() do
      broadcast_game(scope, {:created, game})
      {:ok, game}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking game changes.

  ## Examples

      iex> change_game(scope, game)
      %Ecto.Changeset{data: %Game{}}

  """
  def change_game(%Scope{} = scope, %Game{} = game, attrs \\ %{}) do
    true = game.user_id == scope.user.id

    Game.changeset(game, attrs, scope)
  end
end
