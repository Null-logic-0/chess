defmodule ChessWeb.GameLive.GamePubSubTest do
  use Chess.DataCase, async: true
  alias ChessWeb.GameLive.GamePubSub
  import Chess.AccountsFixtures

  defp game_fixture(user, attrs \\ %{}) do
    scope = %Chess.Accounts.Scope{user: user}
    game = Chess.GamesFixtures.game_fixture(scope, %{})

    game
    |> Ecto.Changeset.cast(Map.new(attrs, fn {k, v} -> {to_string(k), v} end), [
      :white_id,
      :black_id
    ])
    |> Chess.Repo.update!()
  end

  describe "maybe_claim_white/2" do
    test "assigns white when white slot is empty" do
      user = user_fixture()
      game = game_fixture(user, %{white_id: nil})
      updated = GamePubSub.maybe_claim_white(game, user.id)
      assert updated.white_id == user.id
    end

    test "does not change game when white is already taken" do
      user1 = user_fixture()
      user2 = user_fixture()
      game = game_fixture(user1, %{white_id: user1.id})
      result = GamePubSub.maybe_claim_white(game, user2.id)
      assert result.white_id == user1.id
    end
  end

  describe "maybe_join_as_black/3" do
    test "assigns black when conditions are met" do
      white = user_fixture()
      black = user_fixture()
      game = game_fixture(white, %{white_id: white.id, black_id: nil})
      Phoenix.PubSub.subscribe(Chess.PubSub, "game:#{game.slug}")
      updated = GamePubSub.maybe_join_as_black(game, black.id, true)
      assert updated.black_id == black.id
      assert_receive {:opponent_joined, ^updated}
    end

    test "does not assign black when black slot is taken" do
      white = user_fixture()
      black = user_fixture()
      other = user_fixture()
      game = game_fixture(white, %{white_id: white.id, black_id: black.id})
      result = GamePubSub.maybe_join_as_black(game, other.id, true)
      assert result.black_id == black.id
    end

    test "does not assign black when user is already white" do
      user = user_fixture()
      game = game_fixture(user, %{white_id: user.id, black_id: nil})
      result = GamePubSub.maybe_join_as_black(game, user.id, true)
      assert is_nil(result.black_id)
    end

    test "does not assign black when not connected" do
      white = user_fixture()
      black = user_fixture()
      game = game_fixture(white, %{white_id: white.id, black_id: nil})
      result = GamePubSub.maybe_join_as_black(game, black.id, false)
      assert is_nil(result.black_id)
    end
  end

  describe "broadcast_move/2" do
    test "broadcasts move event to subscribers" do
      user = user_fixture()
      game = game_fixture(user)
      Phoenix.PubSub.subscribe(Chess.PubSub, "game:#{game.slug}")
      GamePubSub.broadcast_move(game.slug, game)
      assert_receive {:move, ^game}
    end
  end
end
