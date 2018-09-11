defmodule Bn.MixProject do
  use Mix.Project

  def project do
    [
      app: :bn,
      version: "0.2.1",
      elixir: "~> 1.7",
      description: "BN128 elliptic curve operations for Elixir",
      package: [
        maintainers: ["Ayrat Badykov"],
        licenses: ["MIT", "Apache-2.0"],
        links: %{"GitHub" => "https://github.com/poanetwork/bn"}
      ],
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false},
      {:credo, "~> 0.10.0", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 0.5", only: [:dev, :test], runtime: false}
    ]
  end
end
