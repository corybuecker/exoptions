defmodule Mix.Tasks.Start do
  use Mix.Task
  require Logger

  @impl Mix.Task
  def run(_) do
    Application.ensure_all_started(:exoptions)

    GenStage.sync_subscribe(:tradier_symbols_consumer, to: :tradier_symbols_producer)
    GenStage.sync_subscribe(:tradier_quotes_consumer, to: :tradier_quotes_producer)

    positions = GenServer.call(:tradier_positions, :records)
    Postgrex.query!(:database, "TRUNCATE TABLE tradier_positions", [])

    positions
    |> Enum.each(fn %{"cost_basis" => cost_basis, "symbol" => symbol} ->
      Postgrex.query!(:database, "INSERT INTO tradier_positions VALUES ($1, $2)", [
        symbol,
        cost_basis
      ])
    end)
  end
end
