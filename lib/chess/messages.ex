defmodule Chess.Messages do
  @moduledoc """
  The Messages context.
  """

  import Ecto.Query, warn: false
  alias Chess.Repo
  alias Chess.Games
  alias Chess.Messages.Message
  alias Chess.Accounts.Scope

  @doc """
  Subscribes to scoped notifications about any message changes.

  The broadcasted messages match the pattern:

    * {:created, %Message{}}
    * {:updated, %Message{}}
    * {:deleted, %Message{}}

  """

  def subscribe_messages(slug) do
    Phoenix.PubSub.subscribe(Chess.PubSub, topic(slug))
  end

  defp broadcast_message(slug, message) do
    result = Phoenix.PubSub.broadcast(Chess.PubSub, topic(slug), {:new_message, message})
    result
  end

  defp topic(slug), do: "game:#{slug}"

  @doc """
  Returns the list of messages.

  ## Examples

      iex> list_messages(slug)
      [%Message{}, ...]

  """
  def list_messages(slug) do
    Message
    |> join(:inner, [m], r in Chess.Games.Game, on: r.id == m.game_id)
    |> where([m, r], r.slug == ^slug)
    |> order_by([m], asc: m.inserted_at)
    |> preload(:user)
    |> Repo.all()
  end

  @doc """
  Gets a single message.

  Raises `Ecto.NoResultsError` if the Message does not exist.

  ## Examples

      iex> get_message!(scope, 123)
      %Message{}

      iex> get_message!(scope, 456)
      ** (Ecto.NoResultsError)

  """
  def get_message!(%Scope{} = scope, id) do
    Repo.get_by!(Message, id: id, user_id: scope.user.id)
  end

  @doc """
  Creates a message.

  ## Examples

      iex> create_message(scope,slug, %{field: value})
      {:ok, %Message{}}

      iex> create_message(scope,slug, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_message(%Scope{} = scope, slug, attrs) do
    game = Games.get_game_by_slug!(slug)
    IO.inspect(game, label: "GAME")
    IO.inspect(attrs, label: "ATTRS")

    with {:ok, message} <-
           %Message{game_id: game.id, user_id: scope.user.id}
           |> Message.changeset(attrs, scope)
           |> Repo.insert() do
      message = Repo.preload(message, :user)
      broadcast_message(slug, message)
      {:ok, message}
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking message changes.

  ## Examples

      iex> change_message(scope, message)
      %Ecto.Changeset{data: %Message{}}

  """
  def change_message(%Scope{} = scope, %Message{} = message, attrs \\ %{}) do
    true = message.user_id == scope.user.id

    Message.changeset(message, attrs, scope)
  end
end
