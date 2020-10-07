defmodule Jira.Mixfile do
  use Mix.Project

  @description "An Elixir client library for JIRA + JIRA Agile / Greenhopper"
  @source_url "https://github.com/jeffweiss/jira"

  def project do
    [
      app: :jira,
      version: "0.2.0",
      elixir: "~> 1.8",
      name: "jira",
      description: @description,
      package: package(),
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      docs: docs()
    ]
  end

  def application do
    [applications: [:logger, :mojito], mod: {Jira, []}]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false},
      {:mojito, "~> 0.6"},
      {:jason, "~> 1.0"}
    ]
  end

  defp package do
    [
      maintainers: ["Jeff Weiss"],
      licenses: ["MIT"],
      links: %{"Github" => @source_url}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: [
        "README.md"
      ]
    ]
  end
end
