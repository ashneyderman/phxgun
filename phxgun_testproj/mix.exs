defmodule PhxgunTest.Mixfile do
  use Mix.Project

  def project do
    [
      app: :phxgun_test,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {PhxgunTest.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_),     do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:cowboy, "~> 2.3", override: true},
      # {:cowboy, "~> 1.0"},
      {:phoenix, github: "phoenixframework/phoenix", override: true},
      {:phoenix_pubsub, github: "phoenixframework/phoenix_pubsub", override: true},
      # {:phoenix, "~> 1.3.0"},
      # {:phoenix_pubsub, "~> 1.0"},
      {:gettext, "~> 0.11"},
      {:timex, "~> 3.3"}
    ]
  end
end
