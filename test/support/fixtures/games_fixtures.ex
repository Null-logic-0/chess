defmodule Chess.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chess.Games` context.
  """

  alias Chess.Games
  alias Chess.Accounts.Scope

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        email: "user#{System.unique_integer()}@example.com",
        password: "hello world!",
        full_name: "Test User"
      })
      |> Chess.Accounts.register_user()

    user
  end

  def scope_fixture(user), do: %Scope{user: user}

  def game_fixture(scope, attrs \\ %{}) do
    {:ok, game} = Games.create_game(scope, Enum.into(attrs, %{}))
    game
  end

  def active_game_fixture do
    white = user_fixture()
    black = user_fixture()
    scope = scope_fixture(white)
    game = game_fixture(scope)

    {:ok, game} = Games.join_as_black(game, black.id)
    {:ok, game} = Games.update_game_times(game, game.white_time_ms, game.black_time_ms, "playing")

    %{game: game, white: white, black: black}
  end
end
