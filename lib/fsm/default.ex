defmodule ChatBot.FSM.Default do
  use GenFSM

  # Can I register a bunch of callbacks on my socket connection that update the
  # default FSM state when the socket connection status changes?

  # Should I integrate this default FSM with ChatBot.RoomChannel?

  # Couldn't emulate a (synchronous) FSM in my ChatBot.RoomChannel module as
  # each socket connection has a separate process attached to it?

  # Maybe I should not have this (simple/single state) Default FSM

  alias ChatBot.FSM.State

  def start_link() do
    GenFSM.start_link(__MODULE__, %State{})
  end

  def init(state=%State{}) do
    {:ok, :waiting, state}
  end

  def receive(msg) do
    GenFSM.send_event(__MODULE__, msg)
  end

  def waiting(msg, state=%State{}) do
    {:next_state, :waiting, state}
  end
end
