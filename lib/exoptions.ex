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
      {Postgrex,
       name: :database,
       database: "exoptions",
       hostname: Application.get_env(:exoptions, :host),
       username: "exoptions",
       password: "exoptions"},
      {Finch, name: :http},
      Exoptions.Producers.Tradier.Symbols,
      Exoptions.Producers.Tradier.Quotes,
      Exoptions.Consumers.Tradier.Symbols,
      Exoptions.Consumers.Tradier.Quotes,
      Exoptions.Fetchers.Tradier.Positions
    ]

    Supervisor.start_link(fetchers ++ children, strategy: :rest_for_one)
  end
end
