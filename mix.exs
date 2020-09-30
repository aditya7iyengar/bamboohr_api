defmodule BamboohrApi.MixProject do
  use Mix.Project

  @version "0.0.1"
  @source "https://github.com/aditya7iyengar/bamboohr_api"
  @description """
  An Elixir wrapper around the BambooHR REST API
  """

  def project do
    [
      app: :bamboohr_api,
      description: @description,
      deps: deps(),
      docs: [
        # The main page in the docs
        main: "BamboohrApi",
        extras: ["README.md"]
      ],
      elixir: "~> 1.10",
      homepage_url: @source,
      name: "BambooHR API",
      package: package(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ],
      source_url: @source,
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls],
      version: @version
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def package do
    [
      files: ["lib", "mix.exs", "README.md"],
      maintainers: ["Adi Iyengar"],
      licenses: ["MIT"],
      links: %{"Github" => @source}
    ]
  end

  defp deps do
    [
      {:excoveralls, "~> 0.13.2", only: :test},
      {:exvcr, "~> 0.11.2", only: :test},
      {:ex_doc, "~> 0.22.6", only: :dev, runtime: false},
      {:hackney, "~> 1.16.0"},
      {:jason, "~> 1.2.2"},
      {:tesla, "~> 1.3.3"}
    ]
  end
end
