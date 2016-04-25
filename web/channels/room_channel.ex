defmodule ChatBot.RoomChannel do
  use ChatBot.Web, :channel

  def join("rooms:lobby", payload, socket) do
    if authorized?(payload) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:pong, %{payload: payload}}, socket}
  end

  def handle_in("ping", payload, socket) do
    # Read user_id from socket
    # If user_id not set
    #   disconnect
    # Query in-memory data store
    # If no user data present
    #   Query long term soorage
    # If no user data present
    #   // that's fucked up, how did we get here?
    # If last_seen < 1 day ago
    #   {:noreply, socket}
    # else if last_seen < 7 days ago
    #   {:reply, {:pong, %{payload: short_form}}, socket}
    # else
    #   {:reply, {:pong, %{payload: long_form}}, socket}
    {:reply, {:pong, %{payload: payload}}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (chats:lobby).
  # def handle_in("shout", payload, socket) do
  #   broadcast socket, "shout", payload
  #   {:noreply, socket}
  # end

  # This is invoked every time a notification is being broadcast
  # to the client. The default implementation is just to push it
  # downstream but one could filter or change the event.
  def handle_out(event, payload, socket) do
    push socket, event, payload
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
