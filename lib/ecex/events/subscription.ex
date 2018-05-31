defmodule Ecex.Events.Subscription do
  use Ecex.Events.EventsSchema, Ecex.Subscription

  defmodule Opened do
    defstruct stripe_key: nil, subscription_id: nil, id: nil
    use Ecex.Events.Event
    defdelegate persist!(event), to: Ecex.Events.Subscription
    defdelegate load_aggregate(event), to: Ecex.Events.Subscription
    defdelegate build_aggregate(event), to: Ecex.Events.Subscription

    def apply_event(aggregate, event) do
      {:ok,
       Ecex.Subscription.changeset(aggregate, %{
         stripe_key: event.stripe_key,
         active: false
       })}
    end
  end

  defmodule Activated do
    defstruct subscription_id: nil, id: nil
    use Ecex.Events.Event
    defdelegate persist!(event), to: Ecex.Events.Subscription
    defdelegate load_aggregate(event), to: Ecex.Events.Subscription
    defdelegate build_aggregate(event), to: Ecex.Events.Subscription

    def apply_event(aggregate, _event) do
      {:ok,
       Ecex.Subscription.changeset(aggregate, %{
         active: true
       })}
    end
  end

  @type_module_mapping %{
    Ecex.Events.Subscription.Activated => "activated",
    "activated" => Ecex.Events.Subscription.Activated,
    Ecex.Events.Subscription.Opened => "opened",
    "opened" => Ecex.Events.Subscription.Opened
  }

  def type_module_mapping, do: @type_module_mapping

  def persist!(event) do
    keys =
      event
      |> Map.from_struct()
      |> Map.keys()

    keys = keys -- [:id, :subscription_id]

    {metadata, data} =
      event
      |> Map.take(keys)
      |> Map.pop(:metadata, %{})

    %__MODULE__{
      type: Map.fetch!(@type_module_mapping, event.__struct__),
      id: event.id,
      subscription_id: event.subscription_id,
      data: data,
      metadata: metadata
    }
    |> Ecto.Changeset.cast(%{}, [])
    |> Ecex.Repo.insert!()
  end
end
