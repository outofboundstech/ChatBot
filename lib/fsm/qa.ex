defmodule ChatBot.FSM.QA do

  use GenFSM

  def start_link(questions) do
    state = %{q: questions, a: []}
    GenFSM.start_link(__MODULE__, state)
  end

  def init(state) do
    {:ok, :waiting, state}
  end

  def request(pid, payload) do
    GenFSM.send_event(pid, payload)
  end

  def waiting({sender, ref, nil}, state=%{q: [h|_]}) do
    send sender, {:respond, ref, h}
    {:next_state, :waiting, state}
  end

  def waiting({sender, ref, msg}, %{q: [h|t], a: as}) do
      case t do
        [] ->
          state = %{q: [], a: [{h, msg}|as]}
          send sender, {:ack, ref}
          {:next_state, :complete, state}

        [next|_] ->
          state = %{q: t, a: [{h, msg}|as]}
          send sender, {:respond, ref, next}
          {:next_state, :waiting, state}
      end
  end

  def complete({sender, ref, _}, state) do
    send sender, {:respond, ref, "I'm done with you..."}
    {:next_state, :complete, state}
  end

end
