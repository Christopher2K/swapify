defmodule SwapifyApi.Notifications.JobUpdateNotification do
  @derive Jason.Encoder

  alias SwapifyApi.Tasks.Job

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

  @spec new_platform_sync_update(
          String.t(),
          Job.job_status()
        ) :: t()
  def new_platform_sync_update(
        platform_name,
        status
      ) do
    %__MODULE__{
      name: :sync_platform,
      data: %{
        "platform_name" => platform_name,
        "status" => status
      }
    }
  end

  @spec new_search_tracks_update(
          String.t(),
          String.t(),
          String.t(),
          pos_integer(),
          Job.job_status()
        ) :: t()
  def new_search_tracks_update(
        transfer_id,
        playlist_id,
        platform_name,
        current_index,
        status
      ) do
    %__MODULE__{
      name: :search_tracks,
      data: %{
        "transfer_id" => transfer_id,
        "playlist_id" => playlist_id,
        "platform_name" => platform_name,
        "current_index" => current_index,
        "status" => status
      }
    }
  end

  def new_transfer_tracks_update(
        transfer_id,
        platform_name,
        current_index,
        status
      ) do
    %__MODULE__{
      name: :transfer_tracks,
      data: %{
        "transfer_id" => transfer_id,
        "platform_name" => platform_name,
        "current_index" => current_index,
        "status" => status
      }
    }
  end
end
