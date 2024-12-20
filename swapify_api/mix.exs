defmodule SwapifyApi.MixProject do
  use Mix.Project

  def project do
    [
      app: :swapify_api,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      releases: [
        swapify_api: [
          applications: [
            swapify_api: :permanent,
            opentelemetry_exporter: :permanent,
            opentelemetry: :temporary
          ]
        ]
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {SwapifyApi.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      # {:opentelemetry_oban, "~> 1.1.1"},
      {:argon2_elixir, "~> 4.0"},
      {:bandit, "~> 1.2"},
      {:cors_plug, "~> 3.0"},
      {:dns_cluster, "~> 0.1.1"},
      {:ecto_identifier, "~> 0.2.0"},
      {:ecto_sql, "~> 3.10"},
      {:error_message, "~> 0.2.0"},
      {:esbuild, "~> 0.8.2"},
      {:faker, "~> 0.18", only: :test},
      {:finch, "~> 0.13"},
      {:gettext, "~> 0.20"},
      {:hammer, "~> 6.2.1"},
      {:hammer_backend_mnesia, "~> 0.6"},
      {:hammer_plug, "~> 3.0"},
      {:jason, "~> 1.2"},
      {:joken, "~> 2.6"},
      {:jose, "~> 1.11"},
      {:lucide_live_view, "~> 0.1.1"},
      {:mjml, "~> 4.0"},
      {:nimble_options, "~> 1.0"},
      {:oban, "~> 2.17"},
      {:open_telemetry_decorator, "~> 1.5"},
      {:opentelemetry, "~> 1.5.0"},
      {:opentelemetry_api, "~> 1.4.0"},
      {:opentelemetry_bandit, "~> 0.2.0-rc.2"},
      {:opentelemetry_ecto, "~> 1.2.0"},
      {:opentelemetry_exporter, "~> 1.8.0"},
      {:opentelemetry_phoenix, "~> 2.0.0-rc.1"},
      {:phoenix, "~> 1.7.11"},
      {:phoenix_ecto, "~> 4.4"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:postgrex, ">= 0.0.0"},
      {:recase, "~> 0.8.1"},
      {:req, "~> 0.5.0"},
      {:swoosh, "~> 1.5"},
      {:tailwind, "~> 0.2.4"},
      {:tailwind_formatter, "~> 0.4.0", only: [:dev, :test], runtime: false},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "assets.setup", "assets.build", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      "assets.setup": ["esbuild.install --if-missing", "tailwind.install --if-missing"],
      "assets.build": ["esbuild default", "tailwind default"],
      "assets.deploy": ["esbuild default --minify", "tailwind default --minify", "phx.digest"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
