defmodule Aoc2025.MixProject do
  use Mix.Project

  def project do
    [
      app: :aoc2025,
      version: "0.1.0",
      elixir: "~> 1.16",
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
      {:dotenv_parser, "~> 2.0"},
      {:httpoison, "~> 1.8"},
      {:libgraph, "~> 0.7"},
      {:combination, "~> 0.0"},
      {:levenshtein, "~> 0.3.0"},
      {:gnuplot, "~> 1.22"}

      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
