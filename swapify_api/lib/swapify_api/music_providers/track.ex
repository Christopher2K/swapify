defmodule SwapifyApi.MusicProviders.Track do
  @moduledoc "Business representation of a track"

  use SwapifyApi.Schema

  @type t :: %__MODULE__{
          isrc: String.t() | nil,
          name: String.t(),
          artists: list(String.t()),
          album: String.t()
        }

  embedded_schema do
    field :isrc, :string, default: nil
    field :name, :string
    field :album, :string
    field :artists, {:array, :string}
  end

  @doc "Default changeset"
  def changeset(track, attrs) do
    track
    |> cast(attrs, [:isrc, :name, :album, :artists])
    |> validate_required([:name, :artists, :album])
  end

  @doc "Convert a Spotify track to a business representation"
  @spec from_spotify_track(map()) :: t()
  def from_spotify_track(track),
    do: %__MODULE__{
      album: track["album"]["name"],
      artists: track["artists"] |> Enum.map(fn artist -> artist["name"] end),
      isrc: track["external_ids"]["isrc"],
      name: track["name"]
    }

  @doc "Convert a Apple Music track to a business representation"
  @spec from_apple_music_track(map()) :: t()
  def from_apple_music_track(track) do
    catalog_track =
      if length(track["relationships"]["catalog"]["data"]) > 0 do
        track["relationships"]["catalog"]["data"] |> List.first() |> Map.get("attributes")
      else
        %{}
      end

    %__MODULE__{
      album: track["attributes"]["albumName"],
      artists: [
        track["attributes"]["artistName"]
      ],
      name: track["attributes"]["name"],
      isrc: catalog_track |> Map.get("isrc", nil)
    }
  end

  @doc "Convert a app track to a json compatible map"
  @spec to_map(t()) :: map()
  def to_map(track),
    do: %{
      "isrc" => track.isrc,
      "name" => track.name,
      "artists" => track.artists,
      "album" => track.album
    }
end
