defmodule GiteeCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :gitee_cli,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript(),
      releases: releases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def releases do
    [
      gitee_cli: [
        steps: [:assemble, &Burrito.wrap/1],
        burrito: [
          targets: [
            macos: [os: :darwin, cpu: :x86_64],
            linux: [os: :linux, cpu: :x86_64],
            windows: [os: :windows, cpu: :x86_64]
          ]
        ]
      ]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:owl, "~> 0.9"},
      {:do_it, "~> 0.6"},
      {:jason, "~> 1.2"},
      {:burrito, "~> 1.0"},
      {:ucwidth, "~> 0.2"},
      {:httpoison, "~> 2.0"},
      {:table_rex, "~> 4.0.0"}
    ]
  end

  defp escript do
    [main_module: GiteeCli]
  end
end
