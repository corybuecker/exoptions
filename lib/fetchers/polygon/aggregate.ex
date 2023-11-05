defmodule Exoptions.Fetchers.Polygon.Aggregate do
  require Logger
  use GenServer

  def start_link(_) do
    GenServer.start_link(Exoptions.Fetchers.Polygon.Aggregate, :ok, name: :polygon_aggregate)
  end

  @impl true
  def init(:ok) do
    {:ok, {nil, nil}}
  end

  @impl true
  def handle_call({:records, ticker}, _from, {:finished, nil}) do
    {:reply, [], {ticker, nil}}
  end

  @impl true
  def handle_call({:records, ticker}, _from, {current_ticker, next_url}) do
    data =
      case {current_ticker, next_url} do
        {^ticker, next_url} when not is_nil(next_url) -> fetch(%{next_url: next_url})
        _ -> fetch(%{ticker: ticker})
      end

    case data do
      %{"results" => results, "next_url" => next_url} when results != [] ->
        {:reply, results, {ticker, next_url}}

      %{"results" => results} when results != [] ->
        {:reply, results, {:finished, nil}}

      %{} ->
        {:reply, [], {:finished, nil}}

      other ->
        Logger.error("#{inspect(other)}")
        {:reply, [], {ticker, nil}}
    end
  end

  defp fetch(%{ticker: ticker}) do
    url =
      "https://api.polygon.io/v2/aggs/ticker/#{ticker}/range/1/hour/2023-01-01/2023-12-31?adjusted=true"

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
