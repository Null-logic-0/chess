defmodule Chess.MessagesTest do
  use Chess.DataCase, async: true

  alias Chess.Messages
  alias Chess.Messages.Message

  import Chess.MessagesFixtures
  import Chess.GamesFixtures

  describe "subscribe_messages/1" do
    test "subscriber receives :new_message on create" do
      %{game: game, white: white} = active_game_fixture()
      scope = scope_fixture(white)

      Messages.subscribe_messages(game.slug)
      message_fixture(scope, game.slug, %{"content" => "gg"})

      assert_receive {:new_message, %Message{content: "gg"}}
    end

    test "non-subscriber does not receive broadcast" do
      %{game: game, white: white} = active_game_fixture()
      scope = scope_fixture(white)

      # deliberately do NOT subscribe
      message_fixture(scope, game.slug, %{"content" => "silent"})

      refute_receive {:new_message, _}
    end
  end

  describe "list_messages/1" do
    test "returns messages for the given slug in insertion order" do
      %{game: game, white: white, black: black} = active_game_fixture()

      message_fixture(scope_fixture(white), game.slug, %{"content" => "first"})
      message_fixture(scope_fixture(black), game.slug, %{"content" => "second"})

      messages = Messages.list_messages(game.slug)
      assert length(messages) == 2
      assert Enum.map(messages, & &1.content) == ["first", "second"]
    end

    test "preloads user association" do
      %{game: game, white: white} = active_game_fixture()
      message_fixture(scope_fixture(white), game.slug)

      [message] = Messages.list_messages(game.slug)
      assert %Chess.Accounts.User{} = message.user
    end

    test "returns empty list when no messages exist" do
      %{game: game} = active_game_fixture()
      assert Messages.list_messages(game.slug) == []
    end

    test "does not return messages from a different game" do
      %{game: game1, white: white1} = active_game_fixture()
      %{game: game2} = active_game_fixture()

      message_fixture(scope_fixture(white1), game1.slug, %{"content" => "game1 msg"})

      assert Messages.list_messages(game2.slug) == []
    end
  end

  describe "get_message!/2" do
    test "returns the message for the owning user" do
      %{game: game, white: white} = active_game_fixture()
      scope = scope_fixture(white)
      message = message_fixture(scope, game.slug)

      found = Messages.get_message!(scope, message.id)
      assert found.id == message.id
    end

    test "raises when message belongs to a different user" do
      %{game: game, white: white, black: black} = active_game_fixture()
      message = message_fixture(scope_fixture(white), game.slug)

      assert_raise Ecto.NoResultsError, fn ->
        Messages.get_message!(scope_fixture(black), message.id)
      end
    end

    test "raises for a non-existent id" do
      %{white: white} = active_game_fixture()

      assert_raise Ecto.NoResultsError, fn ->
        Messages.get_message!(scope_fixture(white), -1)
      end
    end
  end

  describe "create_message/3" do
    test "creates a message persisted to the database" do
      %{game: game, white: white} = active_game_fixture()
      scope = scope_fixture(white)

      assert {:ok, %Message{} = message} =
               Messages.create_message(scope, game.slug, %{"content" => "nice move"})

      assert message.content == "nice move"
      assert message.user_id == white.id
      assert message.game_id == game.id
    end

    test "preloads user on the returned message" do
      %{game: game, white: white} = active_game_fixture()

      {:ok, message} =
        Messages.create_message(scope_fixture(white), game.slug, %{"content" => "hi"})

      assert %Chess.Accounts.User{} = message.user
    end

    test "broadcasts :new_message to subscribers" do
      %{game: game, white: white} = active_game_fixture()
      Messages.subscribe_messages(game.slug)

      {:ok, message} =
        Messages.create_message(scope_fixture(white), game.slug, %{"content" => "broadcast me"})

      assert_receive {:new_message, received}
      assert received.id == message.id
    end

    test "returns error changeset for blank content" do
      %{game: game, white: white} = active_game_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Messages.create_message(scope_fixture(white), game.slug, %{"content" => ""})
    end

    test "returns error changeset when content is missing" do
      %{game: game, white: white} = active_game_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Messages.create_message(scope_fixture(white), game.slug, %{})
    end
  end

  describe "change_message/3" do
    test "returns a changeset for the owning user" do
      %{game: game, white: white} = active_game_fixture()
      scope = scope_fixture(white)
      message = message_fixture(scope, game.slug)

      assert %Ecto.Changeset{} = Messages.change_message(scope, message)
    end

    test "raises if scope user does not own the message" do
      %{game: game, white: white, black: black} = active_game_fixture()
      message = message_fixture(scope_fixture(white), game.slug)

      assert_raise MatchError, fn ->
        Messages.change_message(scope_fixture(black), message)
      end
    end
  end
end
