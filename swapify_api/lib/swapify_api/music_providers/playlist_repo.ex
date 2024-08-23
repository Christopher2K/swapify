defmodule SwapifyApi.MusicProviders.PlaylistRepo do
  @moduledoc "Playlist model repository"

  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.Repo
  alias SwapifyApi.Utils

  @doc """
  Create a new playlist from a map
  - data.user_id - ID to use for the playlist
  - data.name - Name of the playlist
  - data.platform_id - Boolean to indicate if the playlist is a library
  - data.platform_name - Name of the platform
  - data.tracks - List of tracks to add to the playlist
  """
  @spec create(map()) :: {:ok, Playlist.t()} | {:error, Ecto.Changeset.t()}
  def create(data) do
    %Playlist{}
    |> Playlist.create_changeset(data)
    |> Repo.insert()
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

  @doc "Get a playlist by its ID"
  @spec get_by_id(String.t()) :: {:ok, Playlist.t()} | {:error, :not_found}
  def get_by_id(id) do
    Playlist.queryable()
    |> Playlist.filter_by(:id, id)
    |> Repo.one()
    |> Utils.from_nullable_to_tuple()
  end

  @doc """
  Add tracks to a playlist and update its status
  New tracks are added under the `+tracks` key of the data map
  """
  @spec update(String.t(), map()) ::
          {:ok, Playlist.t()} | {:error, :not_found}
  def update(id, data) do
    with {:ok, playlist} <- get_by_id(id),
         changeset <- Playlist.update_changeset(playlist, data) do
      Repo.update(changeset, returning: true)
    end
  end
end
