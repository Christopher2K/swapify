defmodule SwapifyApi.MusicProviders.PlaylistRepo do
  @moduledoc "Playlist model repository"

  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.Repo
  alias SwapifyApi.Utils

  @doc """
  Create a new playlist from a map
  - data.user_id - ID to use for the playlist
  - data.platform_name - Name of the platform
  - data.tracks - List of tracks to add to the playlist
  - data.is_library - Boolean to indicate if the playlist is a library
  - data.name - Name of the playlist
  """
  @spec create(map()) :: {:ok, Playlist.t()} | {:error, Ecto.Changeset.t()}
  def create(data) do
    %Playlist{}
    |> Playlist.create_changeset(data)
    |> Repo.insert()
  end

  @doc """
  Update a playlist
  - playlist_id - ID of the playlist to update
  - tracks - List of tracks to add to the playlist
  """
  @spec update(String.t(), list(Track.t())) ::
          {:ok, Playlist.t()} | {:error, :not_found} | {:error, Ecto.Changeset.t()}
  def update(playlist_id, tracks) do
    with {:ok, playlist} <-
           Playlist.queryable()
           |> Playlist.filter_by(:id, playlist_id)
           |> Repo.one()
           |> Utils.from_nullable_to_tuple() do
      playlist
      |> Playlist.update_changeset(%{tracks: tracks})
      |> Repo.update()
    end
  end

  @doc "Get a playlist by its ID and platform"
  @spec get_library_by_user_id_and_platform(String.t(), String.t()) ::
          {:ok, list(Playlist.t())} | {:error, :not_found}
  def get_library_by_user_id_and_platform(user_id, platform) do
    Playlist.queryable()
    |> Playlist.filter_by(:user_id, user_id)
    |> Playlist.filter_by(:platform_name, platform)
    |> Playlist.filter_by(:is_library, true)
    |> Repo.one()
    |> Utils.from_nullable_to_tuple()
  end

  @doc "Get all the user libraries"
  @spec get_user_libraries(String.t()) :: {:ok, list(Playlist.t())}
  def get_user_libraries(user_id) do
    {:ok,
     Playlist.queryable()
     |> Playlist.filter_by(:user_id, user_id)
     |> Playlist.filter_by(:is_library, true)
     |> Repo.all()}
  end
end
