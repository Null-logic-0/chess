defmodule Chess.GamesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Chess.Games` context.
  """

  @doc """
  Generate a game.
  """
  def game_fixture(scope, attrs \\ %{}) do
    attrs =
      Enum.into(attrs, %{
        slug: "some slug"
      })

    {:ok, game} = Chess.Games.create_game(scope, attrs)
    game
  end
end
