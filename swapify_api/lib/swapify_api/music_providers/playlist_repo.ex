defmodule SwapifyApi.MusicProviders.PlaylistRepo do
  @moduledoc "Playlist model repository"

  import Ecto.Query

  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.Repo
  alias SwapifyApi.Utils
  alias SwapifyApi.MusicProviders.Track

  @doc """
  Create a new playlist from a map
  - data.user_id - ID to use for the playlist
  - data.name - Name of the playlist
  - data.platform_id - Boolean to indicate if the playlist is a library
  - data.platform_name - Name of the platform
  - data.tracks_total - How many tracks there is in this playlist
  """
  @spec create(map()) :: {:ok, Playlist.t()} | {:error, Ecto.Changeset.t()}
  def create(data) do
    %Playlist{}
    |> Playlist.create_changeset(data)
    |> Repo.insert()
  end

  @doc """
  Create or update a playlist with some new informations
  """
  @spec create_or_update(
          Playlist.platform_name(),
          String.t(),
          String.t(),
          String.t(),
          pos_integer(),
          Playlist.sync_status()
        ) ::
          {:ok, Playlist.t()} | {:error, Ecto.Changeset.t()}
  def create_or_update(
        platform_name,
        platform_id,
        user_id,
        tracks_total,
        sync_status \\ :unsynced,
        name \\ nil
      ) do
    %Playlist{
      name: name,
      platform_id: platform_id,
      platform_name: platform_name,
      user_id: user_id,
      tracks_total: tracks_total,
      sync_status: sync_status
    }
    |> Repo.insert(
      on_conflict: [
        set: [
          name: name,
          platform_id: platform_id,
          platform_name: platform_name,
          user_id: user_id,
          tracks_total: tracks_total,
          sync_status: sync_status
        ]
      ],
      conflict_target: [:user_id, :platform_id, :platform_name],
      returning: true
    )
  end

  @spec add_tracks(String.t(), list(Track.t()), pos_integer(), Playlist.sync_status(), [
          {:erase_tracks, bool()}
        ]) ::
          {:ok, Playlist.t()} | {:error, :not_found}
  def add_tracks(playlist_id, tracks, tracks_total, status, opts \\ []) do
    should_replace_tracks? = Keyword.get(opts, :replace_tracks, false)

    if should_replace_tracks? do
      from p in Playlist,
        where: [id: ^playlist_id],
        update: [
          set: [
            tracks: ^tracks,
            sync_status: ^status,
            tracks_total: ^tracks_total,
            updated_at: ^DateTime.utc_now()
          ]
        ]
    else
      from p in Playlist,
        where: [id: ^playlist_id],
        update: [
          set: [
            tracks: fragment("? || ?", p.tracks, ^tracks),
            sync_status: ^status,
            tracks_total: ^tracks_total,
            updated_at: ^DateTime.utc_now()
          ]
        ]
    end
    |> Repo.update_all([])
    |> case do
      {1, _} -> get_by_id(playlist_id)
      _ -> {:error, :not_found}
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

  @doc """
  Get the latest library playlist for a given user and platform
  """
  @spec get_latest_library(String.t(), String.t()) :: {:ok, Playlist.t()} | {:error, :not_found}
  def get_latest_library(user_id, platform_name) do
    Playlist.queryable()
    |> Playlist.filter_by(:user_id, user_id)
    |> Playlist.filter_by(:is_library, true)
    |> Playlist.filter_by(:platform_name, platform_name)
    |> Playlist.order_by_asc(:updated_at)
    |> Repo.one()
    |> Utils.from_nullable_to_tuple()
  end
end
