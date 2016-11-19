defmodule UeberauthTwitch.Mixfile do
  use Mix.Project

  @version "0.1.0"
  @url "https://github.com/eein/ueberauth_twitch"

  def project do
    [app: :ueberauth_twitch,
     version: @version,
     name: "Ueberauth Twitch Strategy",
     package: package,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     source_url: @url,
     homepage_url: @url,
     description: description,
     deps: deps,
     docs: docs]
  end

  def application do
    [applications: [:logger, :oauth2, :ueberauth]]
  end

  defp deps do
    [{:ueberauth, "~> 0.4"},
     {:oauth2, "0.6.0"},
     {:ex_doc, "~> 0.3", only: :dev},
     {:earmark, ">= 0.0.0", only: :dev}]
  end

  defp docs do
    [extras: ["README.md", "CONTRIBUTING.md"]]
  end

  defp description do
    "An Uberauth strategy for Twitch authentication."
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: ["William Volin"],
     licenses: ["MIT"],
     links: %{"GitHub": @url}]
  end
end
