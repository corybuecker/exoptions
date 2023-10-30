defmodule Exoptions.Fetchers.Polygon.Chains do
  use GenServer
  require Logger

  def start_link(symbol \\ []) do
    GenServer.start_link(Exoptions.Fetchers.Polygon.Chains, symbol, name: :polygon_chains)
  end

  @impl true
  def init(symbol) do
    {:ok,
     if symbol == [] do
       Application.get_env(:exoptions, :symbols)
     else
       symbol
     end}
  end

  @impl true
  def handle_call(:records, _from, symbols) when symbols == [] do
    {:reply, :finished, []}
  end

  @impl true
  def handle_call(:records, _from, symbols) do
    [symbol | rest] = symbols

    records = GenServer.call(symbol, :records)
    Logger.debug("received #{length(records)} records")

    case length(records) do
      0 -> {:reply, [], rest}
      _ -> {:reply, records, symbols}
    end
  end
end
