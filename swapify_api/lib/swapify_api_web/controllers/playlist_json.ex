defmodule SwapifyApiWeb.PlaylistJSON do
  alias SwapifyApi.MusicProviders

  def index(%{playlists: playlists}), do: %{"data" => MusicProviders.PlaylistJSON.list(playlists)}
  def index(%{playlist: playlist}), do: %{"data" => [MusicProviders.PlaylistJSON.show(playlist)]}
end
