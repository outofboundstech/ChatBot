defmodule ChatBot.FSM.QA do

  use GenFSM

  def start_link(questions=[h|t]) do
    state =
      %{
        pending: h,
        unanswered: t,
        answered: []
      }
    GenFSM.start_link(__MODULE__, state)
  end

  def init(state) do
    {:ok, :waiting, state}
  end

  def request(pid, payload) do
    GenFSM.send_event(pid, payload)
  end

  # Maybe I should just pass pid every time...
  def waiting({sender, ref, msg}, state) do
    # Let's begin with echo'ing the messages that come in
    send sender, {:respond, ref, msg}
    {:next_state, :waiting, state}
  end

end
