defmodule GiteeCli.MixProject do
  use Mix.Project

  def project do
    [
      app: :gitee_cli,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      escript: escript()
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
      {:owl, "~> 0.9"},
      {:do_it, "~> 0.6"},
      {:jason, "~> 1.2"},
      {:ucwidth, "~> 0.2"},
      {:httpoison, "~> 2.0"},
      {:table_rex, "~> 4.0.0"}
    ]
  end

  defp escript do
    [main_module: GiteeCli]
  end
end
