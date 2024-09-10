defmodule SwapifyApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  require Logger

  alias SwapifyApi.MusicProviders.Jobs.SyncLibraryJobEvents
  alias SwapifyApi.MusicProviders.Jobs.SyncPlatformJobEvents

  use Application

  @impl true
  def start(_type, _args) do
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

    :ok = setup_oban_job_telemetry("sync_library", &SyncLibraryJobEvents.handle_event/4)
    :ok = setup_oban_job_telemetry("sync_platform", &SyncPlatformJobEvents.handle_event/4)

    :ok
  end

  defp setup_oban_job_telemetry(job_name, callback) do
    with :ok <-
           :telemetry.attach(
             "#{job_name}-oban-job-started",
             [:oban, :job, :start],
             callback,
             []
           ),
         :ok <-
           :telemetry.attach(
             "#{job_name}-oban-job-stop",
             [:oban, :job, :stop],
             callback,
             []
           ),
         :ok <-
           :telemetry.attach(
             "#{job_name}-oban-job-exceptions",
             [:oban, :job, :exception],
             callback,
             []
           ) do
      :ok
    end
  end
end
