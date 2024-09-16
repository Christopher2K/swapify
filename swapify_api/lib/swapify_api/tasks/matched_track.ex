defmodule SwapifyApi.Tasks.MatchedTrack do
  @moduledoc "Business representation of a track found on another platform during a transfer"
  @derive Jason.Encoder

  use Ecto.Schema

  import Ecto.Changeset

  @type t :: %__MODULE__{
          isrc: String.t(),
          platform_id: String.t(),
          platform_link: String.t()
        }

  embedded_schema do
    field :isrc, :string
    field :platform_id, :string
    field :platform_link, :string
  end

  def changeset(matched_tracks, attrs \\ %{}),
    do:
      matched_tracks
      |> cast(attrs, [:isrc, :platform_id, :platform_link])
      |> validate_required([:isrc, :platform_id, :platform_link])
end
