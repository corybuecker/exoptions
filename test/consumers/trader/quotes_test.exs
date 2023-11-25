defmodule Exptions.Consumers.Trader.QuotesTest do
  alias Exoptions.Consumers.Tradier.Quotes
  alias Exptions.Consumers.Trader.QuotesTest.Producer
  use ExUnit.Case, async: true

  defmodule Producer do
    use GenStage

    def start_link() do
      GenStage.start_link(Producer, 0)
    end

    def init(demand) do
      {:producer, demand}
    end

    def handle_demand(demand, state) do
      {:noreply, [[]], state}
    end
  end

  test "writing quotes" do
    Quotes.handle_events(
      [ok: %{"quotes" => %{"quote" => [%{"symbol" => "AAPL", "trade_date" => 1_699_620_209}]}}],
      0,
      %{}
    )

    assert true
  end
end
