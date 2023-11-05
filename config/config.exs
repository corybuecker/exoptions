import Config

config :exoptions, symbols: [:v, :vz, :nvda, :coin, :pep, :xom, :wmt, :jnj, :zm, :aapl]
config :exoptions, :polygon, key: System.get_env("API_KEY") || ""
config :exoptions, :tradier, key: System.get_env("TRADIER_KEY")
config :logger, :console, level: :all
