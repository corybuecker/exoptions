defmodule Exoptions.Producers.Tradier.Symbols do
  use GenStage

  def start_link(_) do
    GenStage.start_link(Exoptions.Producers.Tradier.Symbols, [], name: :tradier_symbols_producer)
  end

  def init(_) do
    {:producer, %{}}
  end

  def handle_demand(_demand, state) do
    case GenServer.call(:tradier_symbols, :records) do
      records when records != [] -> {:noreply, [records], state}
      [] -> {:noreply, [], state, :hibernate}
    end
  end
end
