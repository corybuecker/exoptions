defmodule Stockbq.Producer do
  use GenStage
  require Logger

  def start_link(_) do
    GenStage.start_link(Stockbq.Producer, :ok, name: A)
  end

  def init(:ok) do
    {:producer, 0}
  end

  def handle_info(:finished, state) do
    Logger.info("stopping producer")
    {:stop, :normal, state}
  end

  def handle_demand(incoming_demand, existing_demand) do
    Logger.debug("incoming demand #{Integer.to_string(incoming_demand)}")
    Logger.debug("existing demand #{Integer.to_string(existing_demand)}")

    GenStage.cast(A, :fetch)

    {:noreply, [], existing_demand + incoming_demand}
  end

  def handle_case(:fetch, existing_demand) when existing_demand <= 0 do
    {:noreply, [], 0}
  end

  def handle_cast(:fetch, existing_demand) do
    Logger.debug("fetch has #{existing_demand} demand")
    events = GenServer.call(Stockbq.Fetchers.All, :records)

    case events do
      :finished ->
        GenStage.async_info(A, :finished)
        {:noreply, [], existing_demand}

      l when is_list(l) and length(l) < existing_demand ->
        GenStage.cast(A, :fetch)
        {:noreply, events, Enum.max([0, existing_demand - length(events)])}

      _ ->
        {:noreply, events, 0}
    end
  end
end
