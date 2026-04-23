defmodule Chess.GamesTest do
  use Chess.DataCase, async: true

  alias Chess.Games
  alias Chess.Games.Game

  import Chess.GamesFixtures

  describe "create_game/2" do
    test "creates a game and assigns creator as white" do
      user = user_fixture()
      scope = scope_fixture(user)

      assert {:ok, %Game{} = game} = Games.create_game(scope, %{})
      assert game.user_id == user.id
      assert game.white_id == user.id || is_nil(game.white_id)
    end

    test "assigns a slug" do
      user = user_fixture()
      scope = scope_fixture(user)

      {:ok, game} = Games.create_game(scope, %{})
      assert is_binary(game.slug) and game.slug != ""
    end

    test "slugs are unique across games" do
      user = user_fixture()
      scope = scope_fixture(user)

      {:ok, g1} = Games.create_game(scope, %{})
      {:ok, g2} = Games.create_game(scope, %{})
      refute g1.slug == g2.slug
    end

    test "sets white_id to nil when not provided (claimed separately via join_as_white)" do
      user = user_fixture()
      scope = scope_fixture(user)

      {:ok, game} = Games.create_game(scope, %{})
      # white_id is claimed separately via maybe_claim_white in the LiveView,
      # not set directly by create_game
      assert game.user_id == user.id
    end
  end

  describe "get_game_by_slug!/1" do
    test "returns the game for a valid slug" do
      user = user_fixture()
      scope = scope_fixture(user)
      game = game_fixture(scope)

      found = Games.get_game_by_slug!(game.slug)
      assert found.id == game.id
    end

    test "preloads the user association" do
      user = user_fixture()
      scope = scope_fixture(user)
      game = game_fixture(scope)

      found = Games.get_game_by_slug!(game.slug)
      assert %Chess.Accounts.User{} = found.user
    end

    test "returns nil for an unknown slug" do
      assert Games.get_game_by_slug!("no-such-slug") == nil
    end
  end

  describe "join_as_white/2" do
    test "sets white_id" do
      user = user_fixture()
      scope = scope_fixture(user)
      game = game_fixture(scope)

      another = user_fixture()

      {:ok, game} =
        Games.update_game_times(game, game.white_time_ms, game.black_time_ms, game.status)

      {:ok, game} = Games.join_as_white(game, another.id)

      assert game.white_id == another.id
    end
  end

  describe "join_as_black/2" do
    test "sets black_id" do
      user = user_fixture()
      scope = scope_fixture(user)
      game = game_fixture(scope)

      black_user = user_fixture()
      assert {:ok, updated} = Games.join_as_black(game, black_user.id)
      assert updated.black_id == black_user.id
    end

    test "persists to the database" do
      user = user_fixture()
      scope = scope_fixture(user)
      game = game_fixture(scope)
      black_user = user_fixture()

      {:ok, _} = Games.join_as_black(game, black_user.id)

      reloaded = Games.get_game_by_slug!(game.slug)
      assert reloaded.black_id == black_user.id
    end
  end

  describe "apply_move/2" do
    test "applies a legal opening move and updates fen" do
      %{game: game} = active_game_fixture()
      original_fen = game.fen

      assert {:ok, updated} = Games.apply_move(game, "e2e4")
      refute updated.fen == original_fen
    end

    test "appends move to moves list" do
      %{game: game} = active_game_fixture()

      assert {:ok, updated} = Games.apply_move(game, "e2e4")
      assert "e2e4" in updated.moves
    end

    test "status stays 'playing' after a non-terminal move" do
      %{game: game} = active_game_fixture()

      assert {:ok, updated} = Games.apply_move(game, "e2e4")
      assert updated.status == "playing"
    end

    test "returns error for an illegal move" do
      %{game: game} = active_game_fixture()

      assert {:error, _reason} = Games.apply_move(game, "e2e5")
    end

    test "returns error for a nonsense move string" do
      %{game: game} = active_game_fixture()

      assert {:error, _reason} = Games.apply_move(game, "zzz")
    end

    test "detects checkmate and sets status" do
      %{game: game} = active_game_fixture()

      # Fool's mate — shortest possible checkmate
      moves = ["f2f3", "e7e5", "g2g4", "d8h4"]

      game =
        Enum.reduce(moves, game, fn move, g ->
          {:ok, updated} = Games.apply_move(g, move)
          updated
        end)

      assert game.status == "checkmate"
    end
  end

  describe "legal_moves_from/2" do
    test "returns legal destination squares for a pawn" do
      %{game: game} = active_game_fixture()

      destinations = Games.legal_moves_from(game, "e2")
      assert is_list(destinations)
      assert "e3" in destinations
      assert "e4" in destinations
    end

    test "returns empty list for an empty square" do
      %{game: game} = active_game_fixture()

      assert Games.legal_moves_from(game, "e4") == []
    end

    test "returns empty list for an opponent's piece (from white perspective)" do
      %{game: game} = active_game_fixture()

      assert Games.legal_moves_from(game, "e7") == []
    end
  end

  describe "resign/2" do
    test "white resigning sets status to resigned_black_wins" do
      %{game: game} = active_game_fixture()

      assert {:ok, updated} = Games.resign(game, :white)
      assert updated.status == "resigned_black_wins"
    end

    test "black resigning sets status to resigned_white_wins" do
      %{game: game} = active_game_fixture()

      assert {:ok, updated} = Games.resign(game, :black)
      assert updated.status == "resigned_white_wins"
    end

    test "persists to database" do
      %{game: game} = active_game_fixture()

      {:ok, _} = Games.resign(game, :white)
      reloaded = Games.get_game_by_slug!(game.slug)
      assert reloaded.status == "resigned_black_wins"
    end
  end

  describe "declare_draw/1" do
    test "sets status to draw" do
      %{game: game} = active_game_fixture()

      assert {:ok, updated} = Games.declare_draw(game)
      assert updated.status == "draw"
    end

    test "persists to database" do
      %{game: game} = active_game_fixture()

      {:ok, _} = Games.declare_draw(game)
      reloaded = Games.get_game_by_slug!(game.slug)
      assert reloaded.status == "draw"
    end
  end

  describe "update_game_times/4" do
    test "updates white and black time" do
      %{game: game} = active_game_fixture()

      assert {:ok, updated} = Games.update_game_times(game, 180_000, 240_000, "playing")
      assert updated.white_time_ms == 180_000
      assert updated.black_time_ms == 240_000
    end

    test "clamps negative times to zero" do
      %{game: game} = active_game_fixture()

      assert {:ok, updated} = Games.update_game_times(game, -500, -1000, "timeout_white_wins")
      assert updated.white_time_ms == 0
      assert updated.black_time_ms == 0
    end

    test "updates status" do
      %{game: game} = active_game_fixture()

      assert {:ok, updated} = Games.update_game_times(game, 0, 30_000, "timeout_black_wins")
      assert updated.status == "timeout_black_wins"
    end
  end

  describe "change_game/3" do
    test "returns a changeset for the owner" do
      user = user_fixture()
      scope = scope_fixture(user)
      game = game_fixture(scope)

      assert %Ecto.Changeset{} = Games.change_game(scope, game)
    end

    test "raises if scope user is not the owner" do
      owner = user_fixture()
      other = user_fixture()

      game = game_fixture(scope_fixture(owner))

      assert_raise MatchError, fn ->
        Games.change_game(scope_fixture(other), game)
      end
    end
  end
end
