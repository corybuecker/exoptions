defmodule Exoptions.Consumers.Tradier.Quotes do
  use GenStage
  require Logger

  def start_link(_) do
    GenStage.start_link(__MODULE__, :ok, name: :tradier_quotes_consumer)
  end

  def init(:ok) do
    {:consumer, %{}}
  end

  def handle_subscribe(:producer, _subscription_options, from, _state) do
    ask_producer(from)
    {:manual, from}
  end

  def handle_events(events, _from, state) do
    case events do
      [[]] ->
        System.stop(0)
        {:noreply, [], state}

      [ok: %{"quotes" => %{"quote" => quotes}}] ->
        quotes
        |> Enum.each(fn %{"symbol" => symbol, "trade_date" => trade_date} = row ->
          Postgrex.query!(
            :database,
            "INSERT INTO tradier_quotes VALUES ($1, $2, $3) ON CONFLICT DO NOTHING",
            [
              trade_date,
              symbol,
              row
            ]
          )
        end)

        {:noreply, [], state}
    end
  end

  def handle_info(:ask, from) do
    ask_producer(from)
    {:noreply, [], from}
  end

  defp ask_producer(from) do
    GenStage.ask(from, 1)

    Process.send_after(self(), :ask, 2500)
  end
end
