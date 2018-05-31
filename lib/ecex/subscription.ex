defmodule Ecex.Subscription do
  use Ecto.Schema

  def events_table_name, do: "subscription_events"
  def event_foreign_key_name, do: :subscription_id

  schema "subscriptions" do
    field(:stripe_key)
    field(:active, :boolean)

    has_many(:events, Ecex.Events.Subscription, foreign_key: :aggregate_id)
    timestamps()
  end

  def changeset(subscription, params) do
    subscription
    |> Ecto.Changeset.cast(params, [:active, :stripe_key])
  end
end

