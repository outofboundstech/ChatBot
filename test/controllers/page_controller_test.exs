defmodule ChatBot.PageControllerTest do
  use ChatBot.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "Free Chats Unlimited"
  end
end
