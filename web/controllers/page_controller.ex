defmodule ChatBot.PageController do
  use ChatBot.Web, :controller

  alias Phoenix.Token, as: Token

  # require Logger

  def index(conn, _params) do
    # Read user_token from conn.session
    # case get_session(conn, :user_token) do
    #   nil ->
    #     # No user_token present:
    #     #   Generate and sign new UID
    #     #   Set as conn.session
    #     uid = 1
    #     # I don't like that second salt parameter
    #     token = Token.sign(conn, "user_id", uid)
    #     conn = put_session(conn, :user_token, token)
    #   user_token ->
    #     {:ok, uid} = Token.verify(conn, "user_id", user_token)
    # end

    render conn, "index.html"
  end

  def authenticate(conn, _params) do
    # Generate a new uid and create the user data in the
    # volatile and/or long term storage
    uid = 1
    # I don't like that second salt parameter
    render conn, "auth.json", bearer_token: Token.sign(conn, "uid", uid)
  end
end
