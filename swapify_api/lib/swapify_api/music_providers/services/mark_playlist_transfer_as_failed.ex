defmodule SwapifyApi.MusicProviders.Services.MarkPlaylistTransferAsFailed do
  @moduledoc "Mark a playlist transfer as failed"
  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.MusicProviders.PlaylistRepo

  @spec call(String.t()) ::
          {:ok, Playlist.t()} | {:error, :not_found}
  def call(playlist_id), do: PlaylistRepo.update(playlist_id, %{sync_status: :error})
end
