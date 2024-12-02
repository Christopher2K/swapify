defmodule SwapifyApiWeb.PlaylistJSON do
  alias SwapifyApi.MusicProviders
  alias SwapifyApi.Operations

  def index(%{playlists: playlists}), do: %{"data" => MusicProviders.PlaylistJSON.list(playlists)}
  def index(%{playlist: playlist}), do: %{"data" => [MusicProviders.PlaylistJSON.show(playlist)]}

  def start_sync_platform_job(%{job: job}), do: %{"data" => Operations.JobJSON.show(job)}

  def start_sync_library_job(%{job: job}), do: %{"data" => Operations.JobJSON.show(job)}
end
