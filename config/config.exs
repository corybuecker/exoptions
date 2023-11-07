import Config

config :exoptions, :tradier,
  key: System.get_env("TRADIER_KEY"),
  account: System.get_env("TRADIER_ACCOUNT")

config :exoptions, host: System.get_env("DATABASE_HOST", "localhost")
config :exoptions, symbols: [:v, :vz, :nvda, :coin, :pep, :xom, :wmt, :jnj, :zm, :aapl, :msft]
config :logger, :console, level: :all
