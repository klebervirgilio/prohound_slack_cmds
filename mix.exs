defmodule ProhoundSlackCmds.MixProject do
  use Mix.Project

  def project do
    [
      app: :prohound_slack_cmds,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ProhoundSlackCmds.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:plug_cowboy, "~> 2.0"},
      {:poolboy, "~> 1.5"},
      {:postgrex, "~> 0.13.5"},
      {:httpoison, "~> 1.4"},
      {:poison, "~> 3.1"},
      {:timex, "~> 3.1"}
    ]
  end
end
