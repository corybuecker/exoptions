defmodule Exoptions.Producers.Tradier.Quotes do
  use GenStage

  def init(_) do
    {:producer, %{}}
  end

  def handle_demand(_demand, state) do
    records = GenServer.call(:tradier_quotes, :records)

    {:noreply, [records], state}
  end
end
