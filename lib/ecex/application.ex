defmodule Ecex.Application do
  use Application

  def start(_type, _args) do
    children = [
      Ecex.Repo,
      {Task.Supervisor, name: Ecex.EventDispatcher}
    ]

    opts = [strategy: :one_for_one, name: Ecex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
