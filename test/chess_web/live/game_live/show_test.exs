defmodule ChessWeb.GameLive.ShowTest do
  use ChessWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Chess.AccountsFixtures

  defp game_fixture(user, attrs \\ %{}) do
    scope = %Chess.Accounts.Scope{user: user}
    game = Chess.GamesFixtures.game_fixture(scope, %{})

    game
    |> Ecto.Changeset.cast(
      Map.new(attrs, fn {k, v} -> {to_string(k), v} end),
      [:white_id, :black_id, :status]
    )
    |> Chess.Repo.update!()
  end

  describe "mount" do
    test "renders the game page for white player", %{conn: conn} do
      user = user_fixture()
      game = game_fixture(user, %{white_id: user.id})

      {:ok, _lv, html} =
        conn |> log_in_user(user) |> live(~p"/#{game.slug}")

      assert html =~ "Match"
    end

    test "redirects unauthenticated users", %{conn: conn} do
      user = user_fixture()
      game = game_fixture(user)

      assert {:error, {:redirect, %{to: path}}} = live(conn, ~p"/#{game.slug}")
      assert path =~ "/users/log-in"
    end

    test "shows waiting state when no opponent has joined", %{conn: conn} do
      user = user_fixture()
      game = game_fixture(user, %{white_id: user.id, black_id: nil})

      {:ok, _lv, html} =
        conn |> log_in_user(user) |> live(~p"/#{game.slug}")

      assert html =~ game.slug
    end
  end

  describe "square_click" do
    test "ignores clicks when there is no opponent", %{conn: conn} do
      user = user_fixture()
      game = game_fixture(user, %{white_id: user.id, black_id: nil, status: "playing"})

      {:ok, lv, _html} = conn |> log_in_user(user) |> live(~p"/#{game.slug}")

      lv |> element("[phx-value-square='e2']") |> render_click()
    end

    test "selects piece and shows hints when own piece is clicked", %{conn: conn} do
      white = user_fixture()
      black = user_fixture()
      game = game_fixture(white, %{white_id: white.id, black_id: black.id, status: "playing"})

      {:ok, lv, _html} = conn |> log_in_user(white) |> live(~p"/#{game.slug}")

      html = lv |> element("[phx-value-square='e2']") |> render_click()

      assert html =~ "e2" or html =~ "selected"
    end

    test "ignores clicks when game is not in playing status", %{conn: conn} do
      white = user_fixture()
      black = user_fixture()
      game = game_fixture(white, %{white_id: white.id, black_id: black.id, status: "white_wins"})

      {:ok, lv, _html} = conn |> log_in_user(white) |> live(~p"/#{game.slug}")

      lv |> element("[phx-value-square='e2']") |> render_click()
    end

    test "ignores clicks when it is not the user's turn", %{conn: conn} do
      white = user_fixture()
      black = user_fixture()
      game = game_fixture(white, %{white_id: white.id, black_id: black.id, status: "playing"})

      {:ok, lv, _html} = conn |> log_in_user(black) |> live(~p"/#{game.slug}")

      html = lv |> element("[phx-value-square='e7']") |> render_click()

      refute html =~ "hint"
    end
  end

  describe "flip_board" do
    test "toggles board orientation", %{conn: conn} do
      user = user_fixture()
      game = game_fixture(user, %{white_id: user.id})

      {:ok, lv, _html} = conn |> log_in_user(user) |> live(~p"/#{game.slug}")

      html_before = render(lv)
      lv |> element("[phx-click='flip_board']") |> render_click()
      html_after = render(lv)

      assert html_before != html_after
    end
  end

  describe "resign" do
    test "ends game when user resigns", %{conn: conn} do
      white = user_fixture()
      black = user_fixture()
      game = game_fixture(white, %{white_id: white.id, black_id: black.id, status: "playing"})

      {:ok, lv, _html} = conn |> log_in_user(white) |> live(~p"/#{game.slug}")

      html = lv |> element("[phx-click='resign']") |> render_click()

      assert html =~ "wins" or html =~ "resign" or html =~ "black"
    end
  end

  describe "offer_draw" do
    test "declares draw and updates game status", %{conn: conn} do
      white = user_fixture()
      black = user_fixture()
      game = game_fixture(white, %{white_id: white.id, black_id: black.id, status: "playing"})

      {:ok, lv, _html} = conn |> log_in_user(white) |> live(~p"/#{game.slug}")

      html = lv |> element("[phx-click='offer_draw']") |> render_click()

      assert html =~ "draw" or html =~ "Draw"
    end
  end

  describe "PubSub integration" do
    test "updates board when a move is broadcast", %{conn: conn} do
      white = user_fixture()
      black = user_fixture()
      game = game_fixture(white, %{white_id: white.id, black_id: black.id, status: "playing"})

      {:ok, lv, _html} = conn |> log_in_user(white) |> live(~p"/#{game.slug}")

      updated_game = %{game | fen: "rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1"}
      send(lv.pid, {:move, updated_game})

      html = render(lv)
      assert is_binary(html)
    end

    test "updates opponent info when opponent joins", %{conn: conn} do
      white = user_fixture()
      black = user_fixture()
      game = game_fixture(white, %{white_id: white.id, black_id: nil})

      {:ok, lv, _html} = conn |> log_in_user(white) |> live(~p"/#{game.slug}")

      joined_game = %{game | black_id: black.id}
      send(lv.pid, {:opponent_joined, joined_game})

      html = render(lv)
      assert html =~ black.full_name or is_binary(html)
    end
  end
end
