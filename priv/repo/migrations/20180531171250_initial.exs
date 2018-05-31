defmodule Ecex.Repo.Migrations.Initial do
  use Ecto.Migration

  def change do
    create table("subscriptions") do
      add :stripe_key, :string
      add :active, :boolean, null: false

      timestamps()
    end

    create table("subscription_events") do
      add :type, :string
      add :subscription_id, :integer, null: false, index: true
      add :data, :map
      add :metadata, :map

      timestamps()
    end
  end
end
