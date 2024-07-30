defmodule SwapifyApi.MusicProviders.Services.GetMusicLibrary do
  @moduledoc "Get the music library of a user"

  require Logger

  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.MusicProviders.Track
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Accounts.Services.RefreshPartnerIntegration

  @spec call(%PlatformConnection{}) :: {:ok, list(Track.t())}
  def call(%PlatformConnection{name: "spotify"} = pc) do
    case do_call(pc, 0, []) do
      {:ok, tracks} ->
        {:ok, tracks}

      {:error, _} ->
        {:error, :service_error}
    end
  end

  @spec do_call(%PlatformConnection{}, pos_integer(), list(Track.t())) ::
          {:ok, list(Track.t())} | {:error, list(Track.t()), any()}
  defp do_call(pc, offset, all_tracks) do
    case Spotify.get_user_library(pc.access_token, offset) do
      {:ok, tracks, response} ->
        has_next = response.body["next"] != nil

        if offset == 0 do
          Logger.info("Starting to get a user library with #{response.body["total"]} tracks")
        end

        if has_next do
          next_offset = offset + 50
          do_call(pc, next_offset, [all_tracks | tracks])
        else
          {:ok, tracks}
        end

      {:error, 401, _} ->
        Logger.error("Failed to read the user library, 401, will attempt to renew the token...")

        case RefreshPartnerIntegration.call(pc) do
          {:ok, refreshed_pc} ->
            do_call(refreshed_pc, offset, all_tracks)

          {:error, _} ->
            Logger.error("Failed to refresh the token, will delete the integration")
            {:error, all_tracks}
        end

      {:error, 429, _response} ->
        # TODO: Handle 429 error
        {:error, all_tracks}

      {:error} ->
        {:error, all_tracks}
    end
  end
end
