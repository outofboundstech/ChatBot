defmodule ChatBot.ChatController do
  use ChatBot.Web, :controller

  def fb_messenger_verify(conn, params) do
    if params["hub.verify_token"] == "secret-token" do
      conn
      |> text(params["hub.challenge"])
    else
      conn
      |> put_status(401)
      |> text("Error, wrong validation token")
    end
  end

  def fb_messenger(conn, params) do
    conn
  end
end
