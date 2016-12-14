defmodule Exreleasy.Mixfile do
  use Mix.Project

  def project do
    [
      app: :exreleasy,
      version: "0.1.6",
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package(),
      dialyzer: [
        plt_add_deps: true,
        plt_add_apps: [:ssl, :eex, :public_key],
        flags: ["-Werror_handling", "-Wrace_conditions"],
      ]
   ]
  end

  def application do
    [applications: [:logger, :mix]]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev},
      {:dialyxir, "~> 0.4", only: [:dev], runtime: false}
    ]
  end

  defp description do
    "A very simple tool for releasing elixir applications."
  end

  defp package do
    [
      name: :exreleasy,
      files: ["lib", "mix.exs", "priv", "README*", "LICENSE"],
      maintainers: ["Miroslav Malkin", "Ilya Averyanov"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/miros/exreleasy"
      }
    ]
  end

end
