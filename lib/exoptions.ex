defmodule Exoptions do
  use Application

  def start(_type, _options) do
    fetchers = [
      Exoptions.Fetchers.Tradier.Symbols.child_spec(Application.get_env(:exoptions, :symbols))
    ]

    children = [
      {Postgrex, name: :database, database: "options"},
      {Finch, name: :http}
    ]

    Supervisor.start_link(fetchers ++ children, strategy: :rest_for_one)
  end
end
