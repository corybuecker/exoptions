defmodule Stockbq.Consumer do
  use GenStage
  require Logger

  def start_link(_opts) do
    GenStage.start_link(Stockbq.Consumer, :ok)
  end

  def init(:ok) do
    {:consumer, :the_state_does_not_matter, subscribe_to: [{A, max_demand: 100}]}
  end

  def handle_events(events, _from, state) do
    events
    |> Enum.each(fn row ->
      case row do
        %{"day" => %{"last_updated" => timestamp}, "details" => %{"ticker" => ticker}} ->
          Postgrex.query!(
            :database,
            "INSERT INTO chains VALUES ($1, $2, $3) ON CONFLICT DO NOTHING",
            [
              timestamp,
              ticker,
              row
            ]
          )

        _ ->
          # Logger.error("unknown row: #{inspect(row)}")
          false
      end
    end)

    Process.sleep(100)
    # We are a consumer, so we would never emit items.
    {:noreply, [], state}
  end
end
