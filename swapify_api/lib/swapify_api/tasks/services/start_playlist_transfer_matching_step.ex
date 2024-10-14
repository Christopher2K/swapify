defmodule SwapifyApi.Tasks.Services.StartPlaylistTransferMatchingStep do
  @moduledoc """
  Start a playlist transfer first step: matching job
  """
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.Tasks
  alias SwapifyApi.Tasks.Transfer
  alias SwapifyApi.Tasks.TransferRepo

  @spec call(
          String.t(),
          String.t(),
          PlatformConnection.platform_name()
        ) ::
          {:ok, Transfer.t()}
  def call(
        user_id,
        playlist_id,
        destination
      ) do
    with {:ok, playlist} <- PlaylistRepo.get_by_id(playlist_id),
         {:ok, transfer} <-
           TransferRepo.create(%{
             "source_playlist_id" => playlist.id,
             "destination" => destination,
             "user_id" => user_id
           }),
         {:ok, job} <-
           Tasks.start_find_playlist_tracks(user_id, destination, playlist.id, transfer.id) do
      TransferRepo.update(transfer, %{"matching_step_job_id" => job.id})
    else
      error -> error
    end
  end
end
