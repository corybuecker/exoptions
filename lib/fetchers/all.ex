defmodule Stockbq.Fetchers.All do
  use GenServer
  require Logger

  def start_link(symbol \\ []) do
    GenServer.start_link(Stockbq.Fetchers.All, symbol, name: Stockbq.Fetchers.All)
  end

  @impl true
  def init(symbol) do
    {:ok,
     if symbol == [] do
       Application.get_env(:stockbq, :symbols)
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
