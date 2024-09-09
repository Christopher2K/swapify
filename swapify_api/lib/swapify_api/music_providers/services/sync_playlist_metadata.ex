defmodule SwapifyApi.MusicProviders.Services.SyncPlaylistMetadata do
  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.Accounts.PlatformConnection

  @spec call(:library | :playlist, PlatformConnection.platform_name(), String.t(), pos_integer()) ::
          {:ok, Playlist.t()} | {:error, atom()}
  def call(:library, platform_name, user_id, tracks_total) do
    PlaylistRepo.create_or_update(platform_name, user_id, user_id, tracks_total)
  end
end
