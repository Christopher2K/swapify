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
end
