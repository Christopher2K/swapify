defmodule SwapifyApi.MusicProviders.Playlist do
  @moduledoc "Playlist content fetched from a music provider"
  require Logger
  use SwapifyApi.Schema

  import Ecto.Query

  alias SwapifyApi.Accounts.User
  alias SwapifyApi.MusicProviders.Track

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          name: String.t(),
          platform_id: String.t(),
          platform_name: String.t(),
          user_id: Ecto.UUID.t(),
          tracks: list(Track.t()),
          tracks_total: pos_integer(),
          sync_status: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "playlists" do
    field :name, :string
    field :platform_id, :string
    field :platform_name, Ecto.Enum, values: [:spotify, :applemusic]
    field :sync_status, Ecto.Enum, values: [:syncing, :synced, :error]

    field :tracks_total, :integer
    embeds_many :tracks, Track, on_replace: :delete

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc "Default changeset"
  def changeset(playlist, attrs) do
    playlist
    |> cast(attrs, [
      :name,
      :platform_id,
      :platform_name,
      :user_id,
      :tracks_total,
      :sync_status
    ])
    |> cast_embed(:tracks)
    |> validate_required([:platform_name, :user_id, :sync_status, :platform_id])
  end

  @doc "Changeset to create a new playlist"
  def create_changeset(playlist, attrs) do
    changeset(playlist, attrs)
  end

  @doc "Changeset to update a playlist and add new tracks"
  def update_changeset(playlist, attrs) do
    cs = changeset(playlist, attrs)
    new_tracks = attrs["+tracks"]

    if new_tracks do
      cs
      |> put_embed(:tracks, Enum.concat(playlist.tracks, attrs["+tracks"]))
    else
      cs
    end
  end

  def to_map(%__MODULE__{} = playlist),
    do: %{
      "id" => playlist.id,
      "name" => playlist.name,
      "platformName" => playlist.platform_name,
      "platformId" => playlist.platform_id,
      "tracksTotal" => playlist.tracks_total,
      "syncStatus" => playlist.sync_status,
      "tracks" => playlist.tracks |> Enum.map(&Track.to_map/1)
    }

  def queryable(), do: from(playlist in __MODULE__, as: :playlist)

  def filter_by(queryable, :id, value), do: where(queryable, [playlist: p], p.id == ^value)

  def filter_by(queryable, :is_library, true),
    do:
      where(
        queryable,
        [playlist: p],
        p.platform_id == ^"library"
      )

  def filter_by(queryable, :is_library, false),
    do:
      where(
        queryable,
        [playlist: p],
        p.platform_id != ^"library"
      )

  def filter_by(queryable, :platform_name, value),
    do: where(queryable, [playlist: p], p.platform_name == ^value)

  def filter_by(queryable, :user_id, value),
    do: where(queryable, [playlist: p], p.user_id == ^value)
end
