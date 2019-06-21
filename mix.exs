defmodule Worldbadges.Mixfile do
  use Mix.Project

  def project do
    [
      app: :worldbadges,
      version: "0.0.1",
      elixir: "~> 1.4",
      elixirc_paths: elixirc_paths(Mix.env),
      compilers: [:phoenix, :gettext] ++ Mix.compilers,
      start_permanent: Mix.env == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Worldbadges.Application, []},
      extra_applications: [:logger, :runtime_tools, :device]
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
      {:phoenix, "~> 1.3.0"},
      {:phoenix_pubsub, "~> 1.0"},
      {:phoenix_ecto, "~> 3.2"},
      {:postgrex, "0.13.5"},
      {:phoenix_html, "~> 2.10"},
      {:phoenix_live_reload, "~> 1.0", only: :dev},
      {:gettext, "~> 0.11"},
      {:cowboy, "~> 1.0"},

      {:comeonin, "~> 2.5"},
      {:guardian, "~> 0.12.0"},
      {:timex, "~> 3.2.1"},
      {:timex_ecto, "~> 3.2.1"},
      {:logger_file_backend, "~> 0.0.9"},
      {:bamboo, "~> 0.8.0"},
      {:bamboo_smtp, "~> 1.3.0"},
      {:ex_aws, "1.1.2"},
      {:exml, "~> 0.1.1"},
      {:geoip, "~> 0.1.2"},
      {:json, "~> 1.0"},
      {:floki, "~> 0.20.3"},
      {:device, "~> 0.3.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "test": ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
