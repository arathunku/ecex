defmodule EcexTest do
  use ExUnit.Case
  use Ecex.DataCase

  doctest Ecex

  test "event store spec" do
    Ecex.Commands.Subscription.Open.call(%{
      id: 9,
      stripe_key: "sub_66",
      metadata: %{notification_id: 33456}
    })

    {:ok, event} = Ecex.Commands.Subscription.Open.call(%{
      id: 10,
      stripe_key: "sub_66123",
      metadata: %{notification_id: 33456}
    })

    subscription = event.__struct__.load_aggregate(event)

    Ecex.Commands.Subscription.Activate.call(%{
      subscription: subscription,
      metadata: %{notification_id: 33456}
    })

    subscription = event.__struct__.load_aggregate(event)

    Ecex.Commands.Subscription.Activate.call(%{
      subscription: subscription,
      metadata: %{notification_id: 33456}
    })

    assert 3 == Ecex.Repo.aggregate(Ecex.Events.Subscription, :count, :id)
    assert 2 == Ecex.Repo.aggregate(Ecex.Subscription, :count, :id)

    assert %{stripe_key: "sub_66", id: 9} = Ecex.Repo.get(Ecex.Subscription, 9)
    assert %{active: true, id: 10} = Ecex.Repo.get(Ecex.Subscription, 10)
  end

  test "events reply" do
    {:ok, _event} = Ecex.Commands.Subscription.Open.call(%{
      id: 9,
      stripe_key: "sub_66",
      metadata: %{notification_id: 33456}
    })


    {:ok, event} = Ecex.Commands.Subscription.Open.call(%{
      id: 10,
      stripe_key: "sub_66123",
      metadata: %{notification_id: 33456}
    })

    subscription = event.__struct__.load_aggregate(event)

    Ecex.Commands.Subscription.Activate.call(%{
      subscription: subscription,
      metadata: %{notification_id: 33456}
    })

    Ecex.Repo.delete_all(Ecex.Subscription)

    Ecex.Events.Subscription.load_events()
    |> Ecex.Commands.Command.persist_events()

    assert 3 == Ecex.Repo.aggregate(Ecex.Events.Subscription, :count, :id)
    assert 2 == Ecex.Repo.aggregate(Ecex.Subscription, :count, :id)

    event = Ecex.Repo.all(Ecex.Events.Subscription) |> List.first |> Ecex.Events.Subscription.present_event()
    assert %{stripe_key: "sub_66"} = event

    assert %{stripe_key: "sub_66", id: 9} = Ecex.Repo.get(Ecex.Subscription, 9)
    assert %{active: true, id: 10} = Ecex.Repo.get(Ecex.Subscription, 10)
  end
end
