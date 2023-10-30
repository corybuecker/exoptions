defmodule Exoptions.Fetchers.Polygon.Aggregates do
  require Logger
  use GenServer

  def start_link(_) do
    GenServer.start_link(Exoptions.Fetchers.Polygon.Aggregates, :ok, name: :polygon_aggregates)
  end

  @impl true
  def init(:ok) do
    {:ok, {nil, []}}
  end

  @impl true
  def handle_call(:records, _from, {nil, []}) do
    %{rows: [[ticker] | tickers]} =
      Postgrex.query!(
        :database,
        "SELECT DISTINCT ticker FROM chains WHERE NOT EXISTS (SELECT 1 FROM aggregates WHERE aggregates.ticker = chains.ticker LIMIT 1)",
        []
      )

    records =
      GenServer.call(:polygon_aggregate, {:records, ticker})
      |> Enum.map(fn r -> r |> Map.put("ticker", ticker) end)

    {:reply, records, {ticker, tickers |> List.flatten()}}
  end

  @impl true
  def handle_call(:records, _from, {ticker, tickers}) do
    records =
      GenServer.call(:polygon_aggregate, {:records, ticker})
      |> Enum.map(fn r -> r |> Map.put("ticker", ticker) end)

    case records do
      [] ->
        [next_ticker | remaining_tickers] = tickers
        {:reply, [], {next_ticker, remaining_tickers}}

      _ ->
        {:reply, records, {ticker, tickers}}
    end
  end
end
