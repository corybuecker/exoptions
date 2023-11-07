defmodule Exoptions.Fetchers.Tradier.Symbols do
  use GenServer
  require Logger

  def start_link(symbols) do
    GenServer.start_link(
      Exoptions.Fetchers.Tradier.Symbols,
      symbols,
      name: :tradier_symbols
    )
  end

  @impl true
  def init(symbols) do
    {:ok, symbols}
  end

  @impl true
  def handle_call(:records, _from, symbols) do
    [symbol | rest] = symbols
    Logger.info("fetching #{url(symbol)}")
    {:ok, %Finch.Response{body: body}} = request(symbol) |> Finch.request(:http)
    data = Jason.decode(body)

    {:reply, data, rest ++ [symbol]}
  end

  defp url(underlying) do
    "https://api.tradier.com/v1/markets/options/lookup?underlying=#{underlying}"
  end

  defp headers do
    [
      {"Accept", "application/json"},
      {"Authorization",
       "Bearer #{Application.get_env(:exoptions, :tradier) |> Keyword.get(:key)}"}
    ]
  end

  defp request(underlying) do
    Finch.build(:get, url(underlying), headers())
  end
end
