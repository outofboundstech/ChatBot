defmodule ChatBot.FacebookController do
  use ChatBot.Web, :controller

  require Logger

  @fb_page_access_token System.get_env("FB_PAGE_ACCESS_TOKEN")

  def verify(conn, params) do
    if params["hub.verify_token"] == "secret-token" do
      conn
      |> text(params["hub.challenge"])
    else
      conn
      |> put_status(401)
      |> text("Error, wrong validation token")
    end
  end

  def handle_in(conn, params) do
    ## See the Facebook messaging API reference at
    #   https://developers.facebook.com/docs/messenger-platform/implementation

    params
    |> Map.get("entry")
    |> hd()
    |> Map.get("messaging")
    |> Enum.each(&handle/1)

    conn
    |> text("Ack")
  end

  defp handle(msg=%{"message" => %{"text" => text}, "sender" => %{"id" => id}}) do
    send_message(id, text)
  end

  defp handle(msg) do
    Logger.info("Unhandled message:\n#{inspect msg}")
  end

  defp send_message(recipient, text) do
    payload = %{
      recipient: %{id: recipient},

      message: %{
        text: text
      }
    }

    url = "https://graph.facebook.com/v2.6/me/messages?access_token=#{@fb_page_access_token}"
    headers = [{"Content-Type", "application/json"}]
    HTTPoison.post!(url, Poison.encode!(payload), headers)
  end
end
