defmodule Exoptions do
  use Application
  alias Exoptions.Fetchers.Tradier.Quotes
  alias Exoptions.Fetchers.Tradier.Symbols

  def start(_type, _options) do
    fetchers = [
      Symbols.child_spec(Application.get_env(:exoptions, :symbols)),
      Quotes.child_spec([])
    ]

    children = [
      {Postgrex, name: :database, database: "exoptions"},
      {Finch, name: :http}
    ]

    Supervisor.start_link(fetchers ++ children, strategy: :rest_for_one)
  end
end
