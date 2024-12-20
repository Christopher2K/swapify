defmodule SwapifyApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  alias SwapifyApi.Operations.TaskEventHandler

  require Logger
  require TaskEventHandler

  use Application

  @impl true
  def start(_type, _args) do
    # OpenTelemetry setup
    OpentelemetryBandit.setup()
    OpentelemetryPhoenix.setup(adapter: :bandit)
    # OpentelemetryEcto.setup([:swapify_api, :repo], db_statement: :enabled)
    # OpentelemetryOban.setup(trace: [:jobs])

    # Rate limiting storage setup
    # if Config.config_env() == :prod do
    # Hammer.Backend.Mnesia.create_mnesia_table()
    # end

    children = [
      SwapifyApiWeb.Telemetry,
      SwapifyApi.Repo,
      {DNSCluster, query: Application.get_env(:swapify_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: SwapifyApi.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: SwapifyApi.Finch},
      # Start a worker by calling: SwapifyApi.Worker.start_link(arg)
      # {SwapifyApi.Worker, arg},
      # Start to serve requests, typically the last entry
      {SwapifyApi.MusicProviders.AppleMusicTokenWorker, name: SwapifyApi.AppleMusicWorker},
      {Task.Supervisor, name: Task.Supervisor},
      SwapifyApiWeb.Endpoint,
      {Oban, Application.fetch_env!(:swapify_api, Oban)}
    ]

    :ok = setup_oban_telemetry()

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SwapifyApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    SwapifyApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end

  defp setup_oban_telemetry() do
    # Careful are this thing will literally LEAK some secrets
    # :ok = Oban.Telemetry.attach_default_logger()

    :ok = TaskEventHandler.register("SwapifyApi.MusicProviders.Jobs.SyncPlatformJob")
    :ok = TaskEventHandler.register("SwapifyApi.MusicProviders.Jobs.SyncLibraryJob")
    :ok = TaskEventHandler.register("SwapifyApi.MusicProviders.Jobs.FindPlaylistTracksJob")
    :ok = TaskEventHandler.register("SwapifyApi.MusicProviders.Jobs.TransferTracksJob")
  end
end
