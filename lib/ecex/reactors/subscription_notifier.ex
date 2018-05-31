defmodule Ecex.Reactors.SubscriptionNotifier do
  def handle(%Ecex.Events.Subscription.Activated{} = event) do
    IO.inspect("SUBSCRIPTION ACTIVATED")
    :ok
  end
end
