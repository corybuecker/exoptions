defmodule Exoptions.Consumers.Tradier.Symbols do
  use GenStage
  require Logger

  def init(_) do
    {:consumer, %{}}
  end

  def handle_subscribe(:producer, _subscription_options, from, _state) do
    ask_producer(from)
    {:manual, from}
  end

  def handle_events(events, _from, state) do
    timestamp = DateTime.utc_now()
    [ok: %{"symbols" => symbols}] = events

    symbols
    |> Enum.each(fn %{"options" => options} ->
      options
      |> Enum.each(fn row ->
        Postgrex.query!(
          :database,
          "INSERT INTO tradier_options VALUES ($1, $2) ON CONFLICT (symbol) DO UPDATE SET fetched_at = $1",
          [
            timestamp,
            row
          ]
        )
      end)
    end)

    {:noreply, [], state}
  end

  def handle_info(:ask, from) do
    ask_producer(from)
    {:noreply, [], from}
  end

  defp ask_producer(from) do
    GenStage.ask(from, 1)

    Process.send_after(self(), :ask, 60000)
  end
end
