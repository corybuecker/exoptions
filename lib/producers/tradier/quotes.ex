defmodule Exoptions.Producers.Tradier.Quotes do
  alias Exoptions.Producers.Tradier.Quotes
  use GenStage

  def start_link(_) do
    GenStage.start_link(Quotes, [], name: :tradier_quotes_producer)
  end

  def init(_) do
    {:producer, %{}}
  end

  def handle_demand(_demand, state) do
    case GenServer.call(:tradier_quotes, :records) do
      records when records != [] ->
        {:noreply, [records], state}

      [] ->
        {:noreply, [[]], state, :hibernate}
    end
  end
end
