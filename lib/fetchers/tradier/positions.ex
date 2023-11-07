defmodule Exoptions.Fetchers.Tradier.Positions do
  use GenServer
  require Logger

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok, name: :tradier_positions)
  end

  @impl true
  def init(:ok) do
    {:ok, []}
  end

  @impl true
  def handle_call(:records, _from, state) do
    with {:ok, %Finch.Response{body: body}} <- request() |> Finch.request(:http),
         {:ok, data} <- Jason.decode(body),
         %{"positions" => %{"position" => positions}} <- data do
      {:reply, positions, state}
    else
      _ ->
        {:reply, [], state}
    end
  end

  defp url() do
    "https://api.tradier.com/v1/accounts/#{Application.get_env(:exoptions, :tradier) |> Keyword.get(:account)}/positions"
  end

  defp headers do
    [
      {"Accept", "application/json"},
      {"Authorization",
       "Bearer #{Application.get_env(:exoptions, :tradier) |> Keyword.get(:key)}"}
    ]
  end

  defp request() do
    Finch.build(:get, url(), headers())
  end
end
