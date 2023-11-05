defmodule Exoptions.Fetchers.Tradier.Quotes do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(Exoptions.Fetchers.Tradier.Quotes, [], name: :tradier_quotes)
  end

  @impl true
  def init(_) do
    {:ok, 0}
  end

  @impl true
  def handle_call(:records, _from, offset) do
    case get_symbols(offset) do
      {:ok, %Postgrex.Result{num_rows: 0}} ->
        {:reply, [], 0}

      {:ok, %Postgrex.Result{rows: rows}} ->
        Logger.info("fetching #{rows |> inspect()}")

        post_body =
          %{"greeks" => true, "symbols" => rows |> List.flatten() |> Enum.join(",")}
          |> URI.encode_query()

        {:ok, %Finch.Response{body: body, headers: headers}} =
          request(post_body) |> Finch.request(:http)

        Logger.info("headers #{headers |> inspect()}")

        data = Jason.decode(body)
        {:reply, data, offset + 500}

      _ ->
        {:reply, [], 0}
    end
  end

  defp get_symbols(offset) do
    Postgrex.query(:database, "SELECT symbol FROM tradier_symbols LIMIT 500 OFFSET $1", [offset])
  end

  defp url() do
    "https://sandbox.tradier.com/v1/markets/quotes"
  end

  defp headers do
    [key: key] = Application.get_env(:exoptions, :tradier)

    [
      {"Accept", "application/json"},
      {"Content-Type", "application/x-www-form-urlencoded"},
      {"Authorization", "Bearer #{key}"}
    ]
  end

  defp request(body) do
    Finch.build(:post, url(), headers(), body)
  end
end
