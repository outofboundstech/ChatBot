defmodule ChatBot.PageController do
  use ChatBot.Web, :controller

  alias Phoenix.Token, as: Token

  # require Logger

  def index(conn, _params) do
    render conn, "index.html"
  end

end
