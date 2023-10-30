defmodule Mix.Tasks.Start do
  use Mix.Task
  require Logger

  @impl Mix.Task
  def run(_) do
    Application.ensure_all_started(:exoptions)

    {:ok, producer} = GenStage.start_link(Exoptions.Producers.Tradier.Symbols, [])
    {:ok, consumer} = GenStage.start_link(Exoptions.Consumers.Tradier.Symbols, [])

    GenStage.sync_subscribe(consumer, to: producer)

    Process.sleep(:infinity)
  end
end
