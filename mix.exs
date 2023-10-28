defmodule Stockbq.MixProject do
  use Mix.Project

  def project do
    [
      app: :stockbq,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Stockbq, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:finch, "~> 0.16"},
      {:gen_stage, "~> 1.2"},
      {:jason, "~> 1.4"},
      {:postgrex, "~> 0.17.3"}
    ]
  end
end
