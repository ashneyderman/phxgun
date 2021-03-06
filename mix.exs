defmodule Phxgun.Mixfile do
  use Mix.Project

  def project do
    [
      app: :phxgun,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
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
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"},
      {:phxgun_test, path: "./phxgun_testproj", only: [:dev, :test]},
      {:gun, "~> 1.0.0-pre.5"},
      {:poison, "~> 3.1"},
      {:elixometer, github: "pinterest/elixometer"},
      {:uuid, "~> 1.1"}
    ]
  end
end
