defmodule Chess.GamesTest do
  use Chess.DataCase

  alias Chess.Games

  describe "games" do
    alias Chess.Games.Game

    import Chess.AccountsFixtures, only: [user_scope_fixture: 0]
    import Chess.GamesFixtures

    @invalid_attrs %{slug: nil}

    test "list_games/1 returns all scoped games" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      game = game_fixture(scope)
      other_game = game_fixture(other_scope)
      assert Games.list_games(scope) == [game]
      assert Games.list_games(other_scope) == [other_game]
    end

    test "get_game!/2 returns the game with given id" do
      scope = user_scope_fixture()
      game = game_fixture(scope)
      other_scope = user_scope_fixture()
      assert Games.get_game!(scope, game.id) == game
      assert_raise Ecto.NoResultsError, fn -> Games.get_game!(other_scope, game.id) end
    end

    test "create_game/2 with valid data creates a game" do
      valid_attrs = %{slug: "some slug"}
      scope = user_scope_fixture()

      assert {:ok, %Game{} = game} = Games.create_game(scope, valid_attrs)
      assert game.slug == "some slug"
      assert game.user_id == scope.user.id
    end

    test "create_game/2 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      assert {:error, %Ecto.Changeset{}} = Games.create_game(scope, @invalid_attrs)
    end

    test "update_game/3 with valid data updates the game" do
      scope = user_scope_fixture()
      game = game_fixture(scope)
      update_attrs = %{slug: "some updated slug"}

      assert {:ok, %Game{} = game} = Games.update_game(scope, game, update_attrs)
      assert game.slug == "some updated slug"
    end

    test "update_game/3 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      game = game_fixture(scope)

      assert_raise MatchError, fn ->
        Games.update_game(other_scope, game, %{})
      end
    end

    test "update_game/3 with invalid data returns error changeset" do
      scope = user_scope_fixture()
      game = game_fixture(scope)
      assert {:error, %Ecto.Changeset{}} = Games.update_game(scope, game, @invalid_attrs)
      assert game == Games.get_game!(scope, game.id)
    end

    test "delete_game/2 deletes the game" do
      scope = user_scope_fixture()
      game = game_fixture(scope)
      assert {:ok, %Game{}} = Games.delete_game(scope, game)
      assert_raise Ecto.NoResultsError, fn -> Games.get_game!(scope, game.id) end
    end

    test "delete_game/2 with invalid scope raises" do
      scope = user_scope_fixture()
      other_scope = user_scope_fixture()
      game = game_fixture(scope)
      assert_raise MatchError, fn -> Games.delete_game(other_scope, game) end
    end

    test "change_game/2 returns a game changeset" do
      scope = user_scope_fixture()
      game = game_fixture(scope)
      assert %Ecto.Changeset{} = Games.change_game(scope, game)
    end
  end
end
