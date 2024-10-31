defmodule SwapifyApi.MusicProviders.PlaylistRepo do
  @moduledoc "Playlist model repository"

  import Ecto.Query

  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.Repo
  alias SwapifyApi.Utils
  alias SwapifyApi.MusicProviders.Track

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
          {:ok, Playlist.t()} | {:error, ErrorMessage.t()}
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
      _ -> {:error, ErrorMessage.not_found("Could not find the requested resource.")}
    end
  end

  @doc "Update playlist status"
  @spec update_status(String.t(), Playlist.sync_status()) ::
          {:ok, Playlist.t()} | {:error, ErrorMessage.t()}
  def update_status(playlist_id, sync_status) do
    Playlist.queryable()
    |> Playlist.filter_by(:id, playlist_id)
    |> update([playlist: p],
      set: [sync_status: ^sync_status]
    )
    |> Repo.update_all([])
    |> case do
      {1, _} ->
        get_by_id(playlist_id)

      _ ->
        {:error, ErrorMessage.not_found("Could not find the requested resource.")}
    end
  end

  @doc "Get a playlist by its ID"
  @spec get_by_id(String.t()) :: {:ok, Playlist.t()} | {:error, ErrorMessage.t()}
  def get_by_id(id) do
    Playlist.queryable()
    |> Playlist.filter_by(:id, id)
    |> Repo.one()
    |> Utils.from_nullable_to_tuple()
  end

  @doc "Get all the user libraries"
  @spec get_user_libraries(String.t(), Playlist.platform_name(), list(Playlist.sync_status())) ::
          {:ok, list(Playlist.t())}
  def get_user_libraries(user_id, platform_name \\ nil, statuses \\ []) do
    {:ok,
     Playlist.queryable()
     |> Playlist.filter_by(:user_id, user_id)
     |> Playlist.is_library(true)
     |> then(fn query ->
       if platform_name do
         Playlist.filter_by(query, :platform_name, platform_name)
       else
         query
       end
     end)
     |> then(fn query ->
       if length(statuses) > 0 do
         Playlist.filter_by(query, :sync_status, statuses)
       else
         query
       end
     end)
     |> Playlist.order_asc(:inserted_at)
     |> Repo.all()}
  end

  @doc """
  Get the latest library playlist for a given user and platform
  """
  @spec get_user_library(String.t(), Playlist.platform_name()) ::
          {:ok, Playlist.t()} | {:error, ErrorMessage.t()}
  def get_user_library(user_id, platform_name) do
    Playlist.queryable()
    |> Playlist.filter_by(:user_id, user_id)
    |> Playlist.filter_by(:platform_name, platform_name)
    |> Playlist.is_library(true)
    |> Repo.one()
    |> Utils.from_nullable_to_tuple()
  end

  @doc """
  Get a specific track by its index
  """
  @spec get_playlist_track_by_index(String.t(), pos_integer()) ::
          {:ok, Track.t()} | {:error, ErrorMessage.t()}
  def get_playlist_track_by_index(playlist_id, index) do
    Playlist.queryable()
    |> Playlist.filter_by(:id, playlist_id)
    |> select([playlist: p], fragment("?[?]", p.tracks, ^Integer.to_string(index)))
    |> Repo.one()
    |> case do
      nil ->
        {:error, ErrorMessage.not_found("Could not find the requested resource.")}

      track ->
        {:ok, Map.merge(%Track{}, Recase.Enumerable.atomize_keys(track))}
    end
  end

  @doc """
  Get a specific subset of tracks
  """
  @spec get_playlist_tracks(String.t(), pos_integer(), pos_integer()) ::
          {:ok, list(Track.t())}
  def get_playlist_tracks(playlist_id, offset, limit) do
    {:ok,
     Playlist.queryable()
     |> Playlist.filter_by(:id, playlist_id)
     |> select([playlist: p], fragment("jsonb_array_elements(?)", p.tracks))
     |> offset(^offset)
     |> limit(^limit)
     |> Repo.all()
     |> Enum.map(fn track ->
       Map.merge(%Track{}, Recase.Enumerable.atomize_keys(track))
     end)}
  end
end
