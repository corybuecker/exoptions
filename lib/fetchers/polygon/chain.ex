defmodule Exoptions.Fetchers.Polygon.Chain do
  require Logger
  use GenServer

  def start_link([symbol]) do
    GenServer.start_link(Exoptions.Fetchers.Polygon.Chain, symbol, name: symbol)
  end

  @impl true
  def init(symbol) do
    # {the stock symbol, the next url, if the load is exhauasted}
    {:ok, {symbol, nil, false}}
  end

  @impl true
  def handle_call(:records, _from, {symbol, _next_url, true}) do
    {:reply, [], {symbol, nil, true}}
  end

  @impl true
  def handle_call(:records, _from, {symbol, _next_url, false} = state) do
    data =
      case state do
        {symbol, next_url, false} when is_nil(next_url) -> fetch(%{symbol: symbol})
        {_symbol, next_url, false} -> fetch(%{next_url: next_url})
      end

    case data do
      %{"results" => results, "next_url" => next_url} when results != [] ->
        {:reply, results, {symbol, next_url, false}}

      %{"results" => results} when results != [] ->
        {:reply, results, {symbol, nil, true}}

      other ->
        Logger.error("#{inspect(other)}")
        {:reply, [], {symbol, nil, true}}
    end
  end

  defp fetch(%{symbol: symbol}) do
    url =
      "https://api.polygon.io/v3/snapshot/options/#{Atom.to_string(symbol) |> String.upcase()}?limit=250"

    request(url)
  end

  defp fetch(%{next_url: next_url}) do
    request(next_url)
  end

  defp request(url) do
    Logger.info("fetching #{url} at #{DateTime.utc_now() |> DateTime.to_string()}")

    Finch.build(:get, url, [{"Authorization", "Bearer #{Application.get_env(:exoptions, :key)}"}])
    |> Finch.request(:http)
    |> parse_response()
  end

  defp parse_response({:ok, %Finch.Response{body: body}}) do
    body |> Jason.decode!() |> Map.take(["results", "next_url"])
  end
end
