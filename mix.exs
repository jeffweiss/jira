defmodule Jira.Mixfile do
  use Mix.Project

  @description """
    An Elixir client library for JIRA + JIRA Agile / Greenhopper
  """

  def project do
    [app: :jira,
     version: "0.0.8",
     elixir: "~> 1.0",
     name: "jira",
     description: @description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [applications: [:logger, :httpoison],
    mod: {Jira, []}]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    [ {:httpoison, ">= 0.6.0"},
      {:poison, ">= 1.4.0"},
    ]
  end

  defp package do
    [ maintainers: ["Jeff Weiss"],
      licenses: ["MIT"],
      links: %{"Github" => "https://github.com/jeffweiss/jira"} ]
  end
end
