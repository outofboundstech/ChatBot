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
    ## Here's what I'll receive:
    #
    # {
    #   "object":"page",
    #   "entry":[
    #     {
    #       "id":"PAGE_ID",
    #       "time":1460245674269,
    #       "messaging":[
    #         {
    #           "sender":{
    #             "id":"USER_ID"
    #           },
    #           "recipient":{
    #             "id":"PAGE_ID"
    #           },
    #           "timestamp":1460245672080,
    #           "message":{
    #             "mid":"mid.1460245671959:dad2ec9421b03d6f78",
    #             "seq":216,
    #             "text":"hello"
    #           }
    #         }
    #       ]
    #     }
    #   ]
    # }

    IO.write(params)
    conn
  end
end
