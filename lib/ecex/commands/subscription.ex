defmodule Ecex.Commands.Subscription do
  defmodule Activate do
    use Ecex.Commands.Command, %{
      subscription: :map
    }

    @impl true
    def process(data, _metadata) do
      {:ok, data}
    end

    @impl true
    def process_attrs(attrs) do
      {:ok, attrs}
    end

    @impl true
    def build_event(command, metadata) do
      if command.subscription.active do
        {:ok, nil}
      else
        {:ok,

          Ecex.Events.Subscription.Activated.build(%{
            subscription_id: command.subscription.id,
            metadata: metadata
          })
        }
      end
    end
  end

  defmodule Open do
    use Ecex.Commands.Command, %{
      id: :binary_id,
      stripe_key: :binary_id
    }

    @impl true
    def process(data, _metadata) do
      {:ok, %{subscription: %{id: data.id}, stripe_key: data.stripe_key}}
    end

    @impl true
    def process_attrs(attrs) do
      {:ok, attrs}
    end

    @impl true
    def build_event(result, metadata) do
      {
        :ok,
        Ecex.Events.Subscription.Opened.build(%{
          subscription_id: result.subscription.id,
          stripe_key: result.stripe_key,
          metadata: metadata
        })
      }
    end
  end
end
