defmodule AdventOfCode2020.MixProject do
  use Mix.Project

  def project do
    [
      app: :advent_of_code_2020,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:libgraph, "~> 0.7"},
      {:memoize, "~> 1.3"},
      {:chunky, "~> 0.13.0"},
      {:mock, "~> 0.3.0", only: :test}
    ]
  end
end
