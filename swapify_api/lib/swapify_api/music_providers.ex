defmodule SwapifyApi.MusicProviders do
  @moduledoc """
  The MusicProviders context.
  """
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Accounts.PlatformConnectionRepo
  alias SwapifyApi.MusicProviders.Jobs.SyncLibraryJob
  alias SwapifyApi.MusicProviders.Jobs.SyncPlatformJob
  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.Tasks
  alias SwapifyApi.Tasks.JobRepo

  @doc """
  Mark a playlist transfer as failed
  """
  @spec mark_playlist_transfer_as_failed(String.t()) ::
          {:ok, Playlist.t()} | SwapifyApi.Errors.t()
  def mark_playlist_transfer_as_failed(playlist_id),
    do: PlaylistRepo.update_status(playlist_id, :error)

  @doc """
  Start a library synchronization job
  """
  @spec start_library_sync(String.t(), PlatformConnection.platform_name()) ::
          {:ok, Playlist.t()} | SwapifyApi.Errors.t()
  def start_library_sync(user_id, platform_name) do
    with {:ok, playlist} <- PlaylistRepo.get_user_library(user_id, platform_name),
         {:ok, pc} <- PlatformConnectionRepo.get_by_user_id_and_platform(user_id, platform_name),
         job_args <-
           SyncLibraryJob.args(
             playlist.id,
             platform_name,
             user_id,
             pc.access_token,
             pc.refresh_token
           ),
         {:ok, db_job} <-
           JobRepo.create(%{
             "name" => "sync_library",
             "status" => :started,
             "user_id" => user_id,
             "oban_job_args" =>
               Map.split(job_args, ["access_token", "refresh_token"]) |> Kernel.elem(1)
           }),
         {:ok, _} <- PlaylistRepo.update_status(playlist.id, :syncing) do
      Map.merge(job_args, %{"job_id" => db_job.id})
      |> SyncLibraryJob.new()
      |> Oban.insert()
      |> Tasks.handle_oban_insertion_error(db_job)
    end
  end

  @doc """
  Start a platform synchronization job
  """
  @spec start_platform_sync(String.t(), PlatformConnection.platform_name()) ::
          {:ok, Job.t()} | SwapifyApi.Errors.t()
  def start_platform_sync(user_id, platform_name) do
    with {:ok, pc} <- PlatformConnectionRepo.get_by_user_id_and_platform(user_id, platform_name),
         job_args <-
           SyncPlatformJob.args(platform_name, user_id, pc.access_token, pc.refresh_token, true),
         {:ok, db_job} <-
           JobRepo.create(%{
             "name" => "sync_platform",
             "status" => :started,
             "user_id" => user_id,
             "oban_job_args" =>
               Map.split(job_args, ["access_token", "refresh_token"]) |> Kernel.elem(1)
           }) do
      Map.merge(job_args, %{"job_id" => db_job.id})
      |> SyncPlatformJob.new()
      |> Oban.insert()
      |> Tasks.handle_oban_insertion_error(db_job)
    end
  end

  @doc """
  Add metadata to an existing or non existing playlist
  """
  @spec sync_playlist_metadata(PlatformConnection.platform_name(), String.t(), pos_integer()) ::
          {:ok, Playlist.t()} | SwapifyApi.Errors.t()
  def sync_playlist_metadata(platform_name, user_id, tracks_total) do
    PlaylistRepo.create_or_update(platform_name, user_id, user_id, tracks_total)
  end
end
