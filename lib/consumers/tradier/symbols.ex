defmodule Exoptions.Consumers.Tradier.Symbols do
  use GenStage
  require Logger

  def start_link(_) do
    GenStage.start_link(Exoptions.Consumers.Tradier.Symbols, [], name: :tradier_symbols_consumer)
  end

  def init(_) do
    {:consumer, %{}}
  end

  def handle_subscribe(:producer, _subscription_options, from, _state) do
    ask_producer(from)
    {:manual, from}
  end

  def handle_events(events, _from, state) do
    [ok: %{"symbols" => symbols}] = events

    symbols
    |> Enum.each(fn %{"options" => options} ->
      options
      |> Enum.each(fn row ->
        Postgrex.query!(
          :database,
          "INSERT INTO tradier_symbols VALUES ($1) ON CONFLICT (symbol) DO UPDATE SET fetched_at = now()",
          [
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

    Process.send_after(self(), :ask, 2500)
  end
end
