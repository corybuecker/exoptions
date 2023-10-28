defmodule Stockbq do
  use Application

  def start(_type, _options) do
    fetchers =
      Application.get_env(:stockbq, :symbols)
      |> Enum.map(fn symbol ->
        Stockbq.Fetchers.Polygon.child_spec([symbol]) |> Map.put(:id, symbol)
      end)

    children = [
      {Postgrex, name: :database, database: "options"},
      {Finch, name: MyFinch},
      Stockbq.Fetchers.All,
      {Stockbq.Producer, []},
      {Stockbq.Consumer, []}
    ]

    Supervisor.start_link(fetchers ++ children, strategy: :rest_for_one)
  end
end
