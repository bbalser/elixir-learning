defmodule ElixirLearning.Mixfile do
  use Mix.Project

  def project do
    [app: :elixirLearning,
     version: "0.0.1",
     elixir: "~> 1.1",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  def application do
    [applications: [:logger],
     mod: {Evercraft, []}]
  end

  defp deps do
    [
      {:ex_parameterized, "~>1.1.0"},
      { :mix_test_watch, "~> 0.4.1", only: :dev, runtime: false },
    ]
  end
end
