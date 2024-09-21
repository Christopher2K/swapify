defmodule SwapifyApi.Tasks.Services.StartPlaylistTransferMatching do
  @moduledoc """
  Start a playlist transfer first step: matching job
  """

  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Tasks.TransferRepo
  alias SwapifyApi.Tasks.Services.StartFindPlaylistTracks

  @spec call(
          String.t(),
          String.t(),
          PlatformConnection.platform_name()
        ) ::
          {:ok}
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
           StartFindPlaylistTracks.call(user_id, destination, playlist.id, transfer.id),
         {:ok} <- TransferRepo.update(transfer, %{"matching_step_job_id" => job.id}) do
      {:ok}
    else
      error -> error
    end
  end
end
