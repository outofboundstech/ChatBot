defmodule ChatBot.FSM.QA do

  use GenFSM

  # Public API

  def start_link(questions) do
    state = %{q: questions, a: []}
    GenFSM.start_link(__MODULE__, state)
  end

  def stop(pid) do
    GenFSM.stop(pid)
  end

  def request(pid, msg) do
    GenFSM.sync_send_event(pid, msg)
  end

  # Internal logic

  def init(state) do
    {:ok, :waiting, state}
  end

  def waiting(nil, _from, state=%{q: [h|_]}) do
    {:reply, {:reply, h}, :waiting, state}
  end

  def waiting(msg, _from, %{q: [h|t], a: as}) do
    case t do
      [] ->
        state = %{q: [], a: [{h, msg}|as]}
        {:reply, :final, :complete, state}

      [next|_] ->
        state = %{q: t, a: [{h, msg}|as]}
        {:reply, {:reply, next}, :waiting, state}
    end
  end

  # Complete sync

  def complete(msg, _from, state) do
    {:reply, :final, :complete, :state}
  end

end
