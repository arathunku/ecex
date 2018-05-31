defmodule Ecex.EventDispatcher do
  @task_supervisor Application.get_env(:ecex, :task_supervisor) || Task.Supervisor
  require Logger

  @handlers %{
    Ecex.Events.Subscription.Activated => [
      {:sync, Ecex.Reactors.SubscriptionNotifier},
      {:async, Ecex.Reactors.SubscriptionNotifier}
    ]
  }

  def dispatch(events) do
    Enum.each(events, fn event ->
      Map.get(@handlers, event.__struct__, [])
      |> case do
        [] ->
          Logger.error("Missing handle for #{event.__struct__}")

        reactors ->
          Enum.each(reactors, &(:ok = handle(&1, event)))
      end
    end)
  end

  defp handle({:sync, reactor}, event) do
    reactor.handle(event)
  end

  defp handle({:async, reactor}, event) do
    @task_supervisor.start_child(__MODULE__, fn ->
      reactor.handle(event)
    end)

    :ok
  end
end
