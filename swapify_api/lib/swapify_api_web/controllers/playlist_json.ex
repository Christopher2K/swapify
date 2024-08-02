defmodule SwapifyApiWeb.PlaylistJSON do
  alias SwapifyApi.MusicProviders.Playlist

  def index(%{playlists: playlists}), do: %{"data" => playlists |> Enum.map(&Playlist.to_map/1)}
end
