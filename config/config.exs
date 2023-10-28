import Config

config :stockbq,
  key: System.get_env("API_KEY") || "",
  symbols: [:v, :vz, :nvda, :coin, :pep, :xom, :wmt, :jnj]

config :logger, :console, level: :all
