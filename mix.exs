defmodule Transmogrify.MixProject do
  use Mix.Project

  def project do
    [
      app: :transmogrify,
      version: "1.0.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      source_url: "https://github.com/srevenant/transmogrify",
      deps: deps(),
      docs: [
        main: "Transmogrify",
        extras: ["README.md"]
      ],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test
      ],
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
      {:mix_test_watch, "~> 0.8", only: [:test, :dev], runtime: false},
      {:excoveralls, "~> 0.14", only: :test},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end

  defp description() do
    """
    Transform map/dictionary keys and values between atoms, strings, camelCase,
    PascalCase, snake_case, and more.
    """
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "Transmogrify",
      # These are the default files included in the package
      files: ~w(lib priv .formatter.exs mix.exs README* readme* LICENSE*
                license* CHANGELOG* changelog* src),
      licenses: ["AGPL-3.0-or-later"],
      links: %{"GitHub" => "https://github.com/srevenant/transmogrify"},
      source_url: "https://github.com/srevenant/transmogrify"
    ]
  end
end
