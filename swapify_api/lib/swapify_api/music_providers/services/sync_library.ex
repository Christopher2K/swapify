defmodule SwapifyApi.MusicProviders.Services.SyncLibrary do
  @moduledoc """
  Synchronize a user library with a given platform
  """
  require Logger

  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.MusicProviders.PlaylistRepo
  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.MusicProviders.Services.GetMusicLibrary
  alias SwapifyApi.MusicProviders.Track

  @spec call(
          String.t(),
          PlatformConnection.t()
        ) :: {:ok, Playlist.t()} | {:error, atom()}
  def call(user_id, platform_connection) do
    case GetMusicLibrary.call(platform_connection) do
      {:ok, tracks} ->
        serialized_tracks = tracks |> Enum.map(&Track.to_map/1)

        case PlaylistRepo.get_library_by_user_id_and_platform(user_id, platform_connection.name) do
          {:ok, playlist} ->
            PlaylistRepo.update(playlist.id, serialized_tracks)

          {:error, :not_found} ->
            PlaylistRepo.create(%{
              "tracks" => serialized_tracks,
              "user_id" => user_id,
              "platform_name" => platform_connection.name,
              "is_library" => true
            })
        end

      {:error, error} ->
        Logger.error("Failed to sync #{platform_connection.name} library for user #{user_id}")
        {:error, error}
    end
  end
end
