defmodule SwapifyApi.Music.Track do
  @moduledoc "Business representation of a track"

  @enforce_keys [:isrc, :name, :artists, :album]
  defstruct isrc: nil, name: nil, artists: [], album: nil

  @type t :: %__MODULE__{
          isrc: String.t(),
          name: String.t(),
          artists: list(String.t()),
          album: String.t()
        }

  @doc "Convert a Spotify track to a business representation"
  @spec from_spotify_track(map()) :: t()
  def from_spotify_track(track),
    do: %__MODULE__{
      album: track["album"]["name"],
      artists: track["artists"] |> Enum.map(fn artist -> artist["name"] end),
      isrc: track["external_ids"]["isrc"],
      name: track["name"]
    }

  # @spec from_apple_music_track(map()) :: t()
  # def from_apple_music_track(track) do
  # end

  @doc "Convert a app track to JSON"
  @spec to_json(t()) :: map()
  def to_json(track),
    do: %{
      "isrc" => track.isrc,
      "name" => track.name,
      "artists" => track.artists,
      "album" => track.album
    }
end
