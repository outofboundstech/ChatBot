defmodule ChatBot.PageController do
  use ChatBot.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
