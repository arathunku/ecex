defmodule Ecex.Events do
  defmodule Event do
    defmacro __using__(_) do
      quote do
        def build(attrs) do
          %__MODULE__{}
          |> Map.merge(attrs)
        end

        def apply_event(event) do
          aggregate = load_aggregate(event) || build_aggregate(event)

          with {:ok, aggregate} <- apply_event(aggregate, event) do
            Ecex.Repo.insert_or_update!(aggregate)
          end
        end
      end
    end
  end

  defmodule EventsSchema do
    @callback build(term, any) :: any | {:error, any}

    defmacro __using__(aggregate) do
      quote do
        @behaviour Ecex.Events.Event
        @aggregate unquote(aggregate)
        @aggregate_attribute @aggregate.event_foreign_key_name()
        @aggregate_events_table_name @aggregate.events_table_name()

        use Ecto.Schema
        require Ecto.Query

        schema @aggregate_events_table_name do
          field(@aggregate_attribute, :integer)
          field(:type, :string)
          field(:data, :map)
          field(:metadata, :map)

          timestamps()
        end

        def load_aggregate(event) do
          if id = Map.fetch!(event, @aggregate_attribute) do
            Ecex.Repo.get(@aggregate, id)
          else
            nil
          end
        end

        def build_aggregate(event) do
          %@aggregate{id: Map.fetch!(event, @aggregate_attribute)}
        end

        def load_events do
          __MODULE__
          |> Ecto.Query.order_by(asc: :id)
          |> Ecex.Repo.all()
          |> Enum.map(&present_event/1)
        end

        def present_event(event) do
          module =
            type_module_mapping
            |> Map.fetch!(event.type)

          AtomicMap.convert(event.data || %{})
          |> Map.put(:metadata, AtomicMap.convert(event.metadata))
          |> Map.put(@aggregate_attribute, Map.fetch!(event, @aggregate_attribute))
          |> Map.put(:id, event.id)
          |> module.build()
        end
      end
    end
  end
end
