defmodule ExPression.MixProject do
  use Mix.Project

  @version "0.3.0"
  @source_url "https://github.com/balance-platform/ex_pression"

  def project do
    [
      app: :ex_pression,
      version: @version,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: "Eval user input expressions in your Elixir project.",
      source_url: @source_url,
      package: package(),
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: []
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # JSON Encode/Decode
      {:jason, "~> 1.4"},
      # PEG parser
      {:xpeg2, "~> 0.9.0"},
      # DEV tools
      # Docs generation
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      # Static Code Analysis
      {:credo, "~> 1.7", only: :dev, runtime: false},
      # Credo formatter
      {:recode, "~> 0.6", only: :dev, runtime: false},
      # Types analysis
      {:dialyxir, "~> 1.4", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Matvey Karpov"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/balance-platform/ex_pression"}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      source_ref: "v#{@version}",
      extras: ["README.md", "LICENSE"],
      filter_modules: "ExPression"
    ]
  end
end
