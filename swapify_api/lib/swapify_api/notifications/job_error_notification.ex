defmodule SwapifyApi.Notifications.JobErrorNotification do
  @derive Jason.Encoder

  defstruct [:name, :data, tag: "JobErrorNotification"]

  @type t :: %__MODULE__{
          name: String.t(),
          data: map()
        }

  @spec new_library_sync_error(
          String.t(),
          Playlist.platform_name()
        ) :: t()
  def new_library_sync_error(
        playlist_id,
        platform_name
      ) do
    %__MODULE__{
      name: :sync_library,
      data: %{
        "playlist_id" => playlist_id,
        "platform_name" => platform_name
      }
    }
  end

  @spec new_platform_sync_error(String.t()) :: t()
  def new_platform_sync_error(platform_name) do
    %__MODULE__{
      name: :sync_platform,
      data: %{
        "platform_name" => platform_name
      }
    }
  end

  @spec new_search_tracks_error(String.t(), String.t()) :: t()
  def new_search_tracks_error(playlist_id, platform_name) do
    %__MODULE__{
      name: :search_tracks,
      data: %{
        "playlist_id" => playlist_id,
        "platform_name" => platform_name
      }
    }
  end

  @spec new_transfer_tracks_error(String.t()) :: t()
  def new_transfer_tracks_error(transfer_id) do
    %__MODULE__{
      name: :transfer_tracks,
      data: %{
        "transfer_id" => transfer_id
      }
    }
  end
end
