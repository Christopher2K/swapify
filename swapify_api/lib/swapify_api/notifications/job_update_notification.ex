defmodule SwapifyApi.Notifications.JobUpdateNotification do
  @derive Jason.Encoder

  defstruct [:name, :data, tag: "JobUpdateNotification"]

  @type t :: %__MODULE__{
          name: String.t(),
          data: map()
        }

  @spec new_library_sync_update(
          String.t(),
          Playlist.platform_name(),
          integer(),
          integer(),
          Playlist.sync_status()
        ) :: t()
  def new_library_sync_update(
        playlist_id,
        platform_name,
        tracks_total,
        synced_tracks_total,
        status
      ) do
    %__MODULE__{
      name: :sync_library,
      data: %{
        "playlist_id" => playlist_id,
        "platform_name" => platform_name,
        "tracks_total" => tracks_total,
        "synced_tracks_total" => synced_tracks_total,
        "status" => status
      }
    }
  end
end
