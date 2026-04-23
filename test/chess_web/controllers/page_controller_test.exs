defmodule ChessWeb.PageControllerTest do
  use ChessWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, ~p"/")
    assert html_response(conn, 200) =~ "Welcome to ChessHub"
    assert html_response(conn, 200) =~ "Play Chess Online with your Firends and Family!"
    assert html_response(conn, 200) =~ "ChessHub"
  end
end
