defmodule ChatBot.FSM.State do

  @type status :: :waiting | :incomplete | :suspended

  @type t :: %ChatBot.FSM.State{status: State.status}

  defstruct status: :waiting

end
