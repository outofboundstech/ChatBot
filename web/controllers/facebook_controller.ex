defmodule ChatBot.FacebookController do
  use ChatBot.Web, :controller

  require Logger

  alias ChatBot.FSM.Registry
  alias ChatBot.FSM.QA

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
    ## Acknowledge receipt of these messages.
    conn
    |> text("Ack")
  end

  defp handle(_msg=%{"message" => %{"attachments" => _attachments}, "sender" => %{"id" => user_id}}) do
    # Set-up an FSM and start my question/answer cycle
    # Handle each of the attachments (download?)
    questions = [
        "What do these pictures show?",
        "Who do these pictures show?",
        "Where did you take these pictures?",
        "When did you take these pictures?"
      ]
      {:ok, pid} = QA.start_link(questions)
      # What do I do when a previous FSM exists?
      _ = Registry.put("fb-messenger", user_id, pid)
      {:reply, response} = QA.request(pid, nil)
      send_message(user_id, response)
  end

  defp handle(_msg=%{"message" => %{"text" => text}, "sender" => %{"id" => user_id}}) do
    # Send message should probably be handled async
    pid = Registry.get("fb-messenger", user_id)
    if pid do
      case QA.request(pid, text) do
        {:reply, response} ->
          send_message(user_id, response)

        :final ->
          # Do some clean-up
          QA.stop(pid)
          Registry.delete("fb-messenger", user_id)
          send_message(user_id, "Thanks a million!")

        _ ->
          # Include :ok
          :ok
      end
    end
  end

  defp handle(_msg=%{"delivery" => _}) do
    # Silently ignore delivery receipts
  end

  defp handle(msg) do
    Logger.info("Unhandled message: #{inspect msg}")
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
