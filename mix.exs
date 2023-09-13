defmodule Transmogrify.MixProject do
  use Mix.Project

  def project do
    [
      app: :transmogrify,
      version: "2.0.0",
      elixir: "~> 1.13",
      description: description(),
      source_url: "https://github.com/srevenant/transmogrify",
      source_ref: "master",
      docs: [
        main: "Transmogrify",
        extras: ["README.md"]
      ],
      package: package(),
      deps: deps(),
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: :test},
      {:mix_test_watch, "~> 1.0", only: [:test, :dev], runtime: false}
    ]
  end

  defp description() do
    """
    Transform map/dictionary keys and values between atoms, strings, camelCase, PascalCase, snake_case, and more.
    """
  end

  defp package() do
    [
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/srevenant/transmogrify"},
      source_url: "https://github.com/srevenant/transmogrify"
    ]
  end
end
