defmodule Ecex.TaskTestSupervisor do
  def async_nolink(_, fun), do: fun.()
  def start_child(_, fun), do: fun.()
end
