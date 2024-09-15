defmodule SwapifyApi.Tasks.Transfer do
  @moduledoc "Business a representation of a playlist transfer"
  use SwapifyApi.Schema

  alias SwapifyApi.Tasks.Job
  alias SwapifyApi.Tasks.MatchedTrack

  schema "transfers" do
    field :platform_source, Ecto.Enum, values: [:spotify, :applemusic]
    field :platform_destination, Ecto.Enum, values: [:spotify, :applemusic]

    belongs_to :matching_step_job, Job
    belongs_to :pre_transfer_step_job, Job
    belongs_to :transfer_step_job, Job

    embeds_many :matched_tracks, MatchedTrack, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(transfer, attrs),
    do:
      transfer
      |> cast(attrs, [
        :platform_source,
        :platform_destination,
        :matching_step_job_id,
        :pre_transfer_step_job_id,
        :transfer_step_job_id,
        :matched_tracks
      ])
      |> validate_required([
        :platform_source,
        :platform_destination
      ])
end
