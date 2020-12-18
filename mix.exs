defmodule LiveViewScreenshots.MixProject do
  use Mix.Project

  def project do
    [
      app: :live_view_screenshots,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: compilers(Mix.env()),
      deps: deps()
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
      {:jason, "~> 1.0", optional: true},
      {:ex_doc, "~> 0.22", only: :docs},
      {:floki, ">= 0.27.0", only: :test},
      {:chrome_remote_interface, "~> 0.4.1"}
    ]
  end
end
