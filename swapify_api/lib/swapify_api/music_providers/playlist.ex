defmodule SwapifyApi.MusicProviders.Playlist do
  @moduledoc "Playlist content fetched from a music provider"
  use SwapifyApi.Schema

  import Ecto.Query

  alias SwapifyApi.Accounts.User
  alias SwapifyApi.MusicProviders.Track

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          name: String.t(),
          platform_name: String.t(),
          is_library: boolean(),
          user_id: Ecto.UUID.t(),
          tracks: list(Track.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "playlists" do
    field :name, :string
    field :platform_name, :string
    field :is_library, :boolean

    embeds_many :tracks, Track, on_replace: :delete

    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc "Default changeset"
  def changetset(playlist, attrs) do
    playlist
    |> cast(attrs, [:name, :platform_name, :is_library, :user_id])
    |> cast_embed(:tracks, required: true)
    |> validate_required([:platform_name, :user_id])
  end

  @doc "Changaset playlist to create a new playlist"
  def create_changeset(playlist, attrs) do
    changetset(playlist, attrs)
  end

  @doc "Changaset playlist to update a playlist"
  def update_changeset(playlist, attrs) do
    playlist
    |> cast(attrs, [])
    |> cast_embed(:tracks, required: true)
  end

  def to_map(%__MODULE__{} = playlist),
    do: %{
      "id" => playlist.id,
      "name" => playlist.name,
      "platformName" => playlist.platform_name,
      "isLibrary" => playlist.is_library,
      "tracks" => playlist.tracks |> Enum.map(&Track.to_map/1)
    }

  def queryable(), do: from(playlist in __MODULE__, as: :playlist)

  def filter_by(queryable, :id, value), do: where(queryable, [playlist: p], p.id == ^value)

  def filter_by(queryable, :is_library, value),
    do: where(queryable, [playlist: p], p.is_library == ^value)

  def filter_by(queryable, :platform_name, value),
    do: where(queryable, [playlist: p], p.platform_name == ^value)

  def filter_by(queryable, :user_id, value),
    do: where(queryable, [playlist: p], p.user_id == ^value)
end
