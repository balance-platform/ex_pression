defmodule ExPression.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_pression,
      version: "0.1.0",
      elixir: "~> 1.11",
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
      # PEG parser
      {:xpeg, git: "https://github.com/zevv/xpeg.git"},
      # DEV tools
      # Static Code Analysis
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      # Credo formatter
      {:recode, "~> 0.6", only: :dev, runtime: false},
      # Types analysis
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false}
    ]
  end
end
