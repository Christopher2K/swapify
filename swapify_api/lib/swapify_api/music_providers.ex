defmodule SwapifyApi.MusicProviders do
  @moduledoc """
  The MusicProviders context.
  """
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Accounts.PlatformConnectionRepo
  alias SwapifyApi.MusicProviders.Jobs.SyncLibraryJob
  alias SwapifyApi.MusicProviders.Jobs.SyncPlatformJob
  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.Operations.JobRepo
  alias SwapifyApi.Repo

  @doc """
  Mark a playlist transfer as failed
  """
  @spec mark_playlist_transfer_as_failed(String.t()) ::
          {:ok, Playlist.t()} | {:error, ErrorMessage.t()}
  def mark_playlist_transfer_as_failed(playlist_id),
    do: PlaylistRepo.update_status(playlist_id, :error)

  @doc """
  Start a library synchronization job
  """
  @spec start_library_sync(String.t(), PlatformConnection.platform_name()) ::
          {:ok, Playlist.t()} | {:error, ErrorMessage.t()}
  def start_library_sync(user_id, platform_name) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:playlist, fn _, _changes ->
      PlaylistRepo.get_user_library(user_id, platform_name)
    end)
    |> Ecto.Multi.run(:pc, fn _, _changes ->
      PlatformConnectionRepo.get_by_user_id_and_platform(user_id, platform_name)
    end)
    |> Ecto.Multi.run(:job_args, fn _, %{playlist: playlist, pc: pc} ->
      {:ok,
       SyncLibraryJob.args(
         playlist.id,
         platform_name,
         user_id,
         pc.access_token,
         pc.refresh_token
       )}
    end)
    |> Ecto.Multi.run(:job, fn _, %{job_args: job_args} ->
      JobRepo.create(%{
        "name" => "sync_library",
        "status" => :started,
        "user_id" => user_id,
        "oban_job_args" =>
          Map.split(job_args, ["access_token", "refresh_token"]) |> Kernel.elem(1)
      })
    end)
    |> Ecto.Multi.run(:update_playlist, fn _, %{playlist: playlist} ->
      PlaylistRepo.update_status(playlist.id, :syncing)
    end)
    |> Ecto.Multi.run(:oban, fn _, %{job: job, job_args: job_args} ->
      Map.merge(job_args, %{"job_id" => job.id})
      |> SyncLibraryJob.new()
      |> Oban.insert()
      |> SwapifyApi.Utils.check_oban_insertion_result()
    end)
    |> Ecto.Multi.run(:result, fn _, %{job: job} ->
      {:ok, job}
    end)
    |> Repo.transaction()
    |> SwapifyApi.Utils.handle_transaction_result()
  end

  @doc """
  Start a platform synchronization job
  """
  @spec start_platform_sync(String.t(), PlatformConnection.platform_name()) ::
          {:ok, Job.t()} | {:error, ErrorMessage.t()} | {:error, Ecto.Changeset.t()}
  def start_platform_sync(user_id, platform_name) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(:pc, fn _, _changes ->
      PlatformConnectionRepo.get_by_user_id_and_platform(user_id, platform_name)
    end)
    |> Ecto.Multi.run(:job_args, fn _, %{pc: pc} ->
      {:ok, SyncPlatformJob.args(platform_name, user_id, pc.access_token, pc.refresh_token, true)}
    end)
    |> Ecto.Multi.run(:job, fn _, %{job_args: job_args} ->
      JobRepo.create(%{
        "name" => "sync_platform",
        "status" => :started,
        "user_id" => user_id,
        "oban_job_args" =>
          Map.split(job_args, ["access_token", "refresh_token"]) |> Kernel.elem(1)
      })
    end)
    |> Ecto.Multi.run(:oban, fn _, %{job: job, job_args: job_args} ->
      Map.merge(job_args, %{"job_id" => job.id})
      |> SyncPlatformJob.new()
      |> Oban.insert()
      |> SwapifyApi.Utils.check_oban_insertion_result()
    end)
    |> Ecto.Multi.run(:result, fn _, %{job: job} ->
      {:ok, job}
    end)
    |> Repo.transaction()
    |> SwapifyApi.Utils.handle_transaction_result()
  end

  @doc """
  Add metadata to an existing or non existing playlist
  """
  @spec sync_playlist_metadata(PlatformConnection.platform_name(), String.t(), pos_integer()) ::
          {:ok, Playlist.t()} | {:error, Changeset.t()}
  def sync_playlist_metadata(platform_name, user_id, tracks_total),
    do: PlaylistRepo.create_or_update(platform_name, user_id, user_id, tracks_total)
end
