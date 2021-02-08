defmodule Elogram.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :elogram,
      version: @version,
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: compilers(Mix.env()),
      deps: deps(),
      docs: docs()
    ]
  end

  defp compilers(:test), do: [:phoenix] ++ Mix.compilers()
  defp compilers(_), do: Mix.compilers()

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:phoenix_live_view, "~> 0.15.0",
       github: "phoenixframework/phoenix_live_view", branch: "master"},
      {:nimble_pool, "~> 0.2"},
      {:jason, "~> 1.0", optional: true},
      {:ex_doc, "~> 0.22", only: :docs},
      {:floki, ">= 0.27.0", only: :test},
      {:chrome_remote_interface, "~> 0.4.1"}
    ]
  end

  defp docs do
    [
      main: "Elogram",
      source_ref: "v#{@version}",
      source_url: "https://github.com/mcrumm/elogram",
      nest_modules_by_prefix: [Elogram]
    ]
  end
end
