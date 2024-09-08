defmodule SwapifyApi.MusicProviders.SyncNotification do
  @moduledoc "Notification of a sync progress"
  @derive Jason.Encoder

  alias SwapifyApi.MusicProviders.Playlist

  @type t :: %__MODULE__{
          playlist_id: String.t(),
          platform_name: Playlist.platform_name(),
          tracks_count: integer(),
          sync_count: integer(),
          status: Playlist.sync_status()
        }

  @enforce_keys [:playlist_id, :platform_name, :tracks_count, :sync_count, :status]
  defstruct playlist_id: nil,
            platform_name: nil,
            tracks_count: nil,
            sync_count: nil,
            status: nil

  def to_json(notification),
    do: Jason.encode(notification) |> Digger.CamelCaser.camel_case(key_transform: :lower)
end
