defmodule ChatBot.ChatController do
  use ChatBot.Web, :controller

  @fb_page_access_token System.get_env("FB_PAGE_ACCESS_TOKEN")

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
    ## See the Facebook messaging API reference at
    #   https://developers.facebook.com/docs/messenger-platform/implementation

    params
    |> Map.get("entry")
    |> hd()
    |> Map.get("messaging")
    |> Enum.each(&fb_handle_message/1)

    conn
    |> text("Ack")
  end

  defp fb_handle_message(msg=%{"message" => %{"text" => text}, "sender" => %{"id" => id}}) do
    fb_send_text_message(id, text)
  end

  defp fb_send_text_message(recipient, text) do
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
