defmodule SwapifyApiWeb.PlaylistController do
  use SwapifyApiWeb, :controller

  alias SwapifyApi.MusicProviders.Services.StartPlatformSync
  alias SwapifyApi.MusicProviders.PlaylistRepo

  @doc """
  Get user libraries for all or a given platform
  """
  def search_library(conn, %{"platform_name" => platform_name}) do
    user_id = conn.assigns[:user_id]

    with {:ok, playlist} <- PlaylistRepo.get_user_library(user_id, platform_name) do
      conn
      |> put_status(200)
      |> render(:index, playlist: playlist)
    end
  end

  def search_library(conn, _) do
    user_id = conn.assigns[:user_id]

    with {:ok, playlists} <- PlaylistRepo.get_user_libraries(user_id) do
      conn
      |> put_status(200)
      |> render(:index, playlists: playlists)
    end
  end

  def start_sync_platform_job(conn, %{"platform_name" => platform_name}) do
    user_id = conn.assigns[:user_id]

    with {:ok, job} <- StartPlatformSync.call(user_id, String.to_atom(platform_name)) do
      conn
      |> put_status(200)
      |> render(:start_sync_platform_job, job: job)
    end
  end

  def start_sync_playlist_job(conn, %{"playlist_id" => playlist_id}) do
    # TODO
    conn |> resp(200, "")
  end
end
