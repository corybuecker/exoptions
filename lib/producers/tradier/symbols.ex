defmodule Exoptions.Producers.Tradier.Symbols do
  use GenStage

  def init(_) do
    {:producer, %{}}
  end

  def handle_demand(_demand, state) do
    records = GenServer.call(:tradier_symbols, :records)

    {:noreply, [records], state}
  end
end
