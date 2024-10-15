defmodule SwapifyApi.MusicProviders.PlaylistJSON do
  alias SwapifyApi.MusicProviders.Playlist

  @fields [
    :id,
    :name,
    :platform_id,
    :platform_name,
    :tracks_total,
    :sync_status,
    :inserted_at,
    :updated_at,
    :user_id
  ]

  def show(%Playlist{} = p) do
    {to_serialize, _} = Map.split(p, @fields)
    to_serialize |> Recase.Enumerable.convert_keys(&Recase.to_camel/1)
  end

  def show(_), do: nil

  def list(playlist_list), do: playlist_list |> Enum.map(&show/1)
end
