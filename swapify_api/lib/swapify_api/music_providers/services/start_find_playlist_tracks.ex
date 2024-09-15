defmodule SwapifyApi.MusicProviders.Services.StartFindPlaylistTracks do
  alias SwapifyApi.MusicProviders.Jobs.FindPlaylistTracksJob
  alias SwapifyApi.Accounts.PlatformConnectionRepo

  def call(user_id, target_platform, playlist_id) do
    with {:ok, pc} <-
           PlatformConnectionRepo.get_by_user_id_and_platform(user_id, target_platform),
         job_args <-
           FindPlaylistTracksJob.args(
             playlist_id,
             target_platform,
             user_id,
             pc.access_token,
             pc.refresh_token
           ) do
      # TODO: Create a job db entry
      job_args |> FindPlaylistTracksJob.new() |> Oban.insert()
      # TODO: Handle error cases situations
    end
  end
end
