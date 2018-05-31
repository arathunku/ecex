defmodule Ecex.Commands do
  defmodule Command do
    @callback process(any, any) :: {:ok, any} | {:error, any}
    @callback process_attrs(any) :: {:ok, any} | {:error, any}
    @callback build_events(any, any) :: {:ok, [any]} | {:error, any}

    defmacro __using__(data_attrs) do
      quote do
        @behaviour Ecex.Commands.Command
        @data_attrs unquote(data_attrs)
        def data_atts, do: @data_attrs

        def call(attrs) do
          {metadata, params} = Map.pop(attrs, :metadata)

          with {:ok, data} <- process_attrs(params),
               {:ok, result} <- process(data, metadata),
               {:ok, event} <- build_event(result, metadata),
               :ok <- Ecex.Commands.Command.persist_events(event) do
            {:ok, event}
          end
        end
      end
    end

    def persist_events(nil), do: :ok

    def persist_events(events) when is_list(events) do
      Ecex.Repo.transaction(fn ->
        Enum.each(events, fn event ->
          event.__struct__.apply_event(event)

          if !event.id do
            event.__struct__.persist!(event)
          end
        end)

        Ecex.EventDispatcher.dispatch(events)
      end)

      :ok
    end

    def persist_events(events), do: persist_events([events])
  end
end
