defmodule SwapifyApiWeb.PlaylistController do
  use SwapifyApiWeb, :controller

  alias SwapifyApi.MusicProviders
  alias SwapifyApi.MusicProviders.PlaylistRepo

  @doc """
  Get user libraries for all or a given platform
  """
  def search_library(conn, params) do
    user_id = conn.assigns[:user_id]

    status = Map.values(params["status"] || %{})
    platform_name = params["platform_name"]

    with {:ok, playlists} <- PlaylistRepo.get_user_libraries(user_id, platform_name, status) do
      conn
      |> put_status(200)
      |> render(:index, playlists: playlists)
    end
  end

  def start_sync_platform_job(conn, %{"platform_name" => platform_name}) do
    user_id = conn.assigns[:user_id]

    with {:ok, job} <- MusicProviders.start_platform_sync(user_id, String.to_atom(platform_name)) do
      conn
      |> put_status(200)
      |> render(:start_sync_platform_job, job: job)
    end
  end

  def start_sync_library_job(conn, %{"platform_name" => platform_name}) do
    user_id = conn.assigns[:user_id]

    # TODO: Check if a synchronization job is already running
    # Since one `Job` is expected to contain multiple Oban.Job
    # I need my own uniqueness job layer
    with {:ok, job} <- MusicProviders.start_library_sync(user_id, String.to_atom(platform_name)) do
      conn
      |> put_status(200)
      |> render(:start_sync_platform_job, job: job)
    end
  end
end
