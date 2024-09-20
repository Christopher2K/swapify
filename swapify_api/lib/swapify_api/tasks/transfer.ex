defmodule SwapifyApi.Tasks.Transfer do
  @moduledoc "Business a representation of a playlist transfer"
  use SwapifyApi.Schema

  alias SwapifyApi.Accounts.User
  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Tasks.Job
  alias SwapifyApi.Tasks.MatchedTrack

  @type t :: %__MODULE__{
          id: String.t(),
          destination: PlatformConnection.platform_name(),
          matching_step_job: Job.t() | nil,
          matching_step_job_id: String.t() | nil,
          pre_transfer_step_job: Job.t() | nil,
          pre_transfer_step_job_id: String.t() | nil,
          transfer_step_job: Job.t() | nil,
          transfer_step_job_id: String.t() | nil,
          source_playlist: Playlist.t() | nil,
          source_playlist_id: String.t() | nil,
          matched_tracks: MatchedTrack.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "transfers" do
    field :destination, Ecto.Enum, values: [:spotify, :applemusic]

    belongs_to :matching_step_job, Job
    belongs_to :pre_transfer_step_job, Job
    belongs_to :transfer_step_job, Job
    belongs_to :source_playlist, Playlist
    belongs_to :user, User

    embeds_many :matched_tracks, MatchedTrack, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(transfer, attrs),
    do:
      transfer
      |> cast(attrs, [
        :destination,
        :matching_step_job_id,
        :pre_transfer_step_job_id,
        :transfer_step_job_id,
        :user_id,
        :source_playlist_id
      ])
      |> cast_embed(:matched_tracks)
      |> validate_required([
        :destination,
        :source_playlist_id,
        :user_id
      ])

  # Queries
  def queryable(), do: from(transfer in __MODULE__, as: :transfer)

  def filter_by(queryable, :id, id), do: queryable |> where([transfer: t], t.id == ^id)

  def filter_by(queryable, :user_id, user_id),
    do: queryable |> where([transfer: t], t.user == ^user_id)

  def order_asc(queryable, :inserted_at),
    do: queryable |> order_by(asc: :inserted_at)
end
