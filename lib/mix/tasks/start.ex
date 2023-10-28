defmodule Mix.Tasks.Start do
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    Mix.Task.run("app.start")
  end
end
