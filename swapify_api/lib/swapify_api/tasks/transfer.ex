defmodule SwapifyApi.Tasks.Transfer do
  @moduledoc "Business a representation of a playlist transfer"
  use SwapifyApi.Schema

  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Accounts.User
  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.MusicProviders.Track
  alias SwapifyApi.Tasks.Job
  alias SwapifyApi.Tasks.MatchedTrack

  @type t :: %__MODULE__{
          id: String.t(),
          destination: PlatformConnection.platform_name(),
          matching_step_job: Job.t() | nil,
          matching_step_job_id: String.t() | nil,
          transfer_step_job: Job.t() | nil,
          transfer_step_job_id: String.t() | nil,
          source_playlist: Playlist.t() | nil,
          source_playlist_id: String.t() | nil,
          matched_tracks: list(MatchedTrack.t()),
          not_found_tracks: list(Track.t()),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  @type transfer_step :: :matching | :transfer

  schema "transfers" do
    field :destination, Ecto.Enum, values: [:spotify, :applemusic]

    belongs_to :matching_step_job, Job
    belongs_to :transfer_step_job, Job
    belongs_to :source_playlist, Playlist
    belongs_to :user, User

    embeds_many :matched_tracks, MatchedTrack, on_replace: :delete
    embeds_many :not_found_tracks, Track, on_replace: :delete

    timestamps(type: :utc_datetime)
  end

  def changeset(transfer, attrs),
    do:
      transfer
      |> cast(attrs, [
        :destination,
        :matching_step_job_id,
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

  def is_cancelled?(%__MODULE__{} = transfer), do: transfer.matching_step_job.status == :canceled

  # Domain invariants
  @doc "If a transfer can be cancelled in its current state"
  def can_be_cancelled?(%__MODULE__{} = transfer),
    do: transfer.matching_step_job.status == :done && transfer.transfer_step_job_id == nil

  # Queries
  def queryable(), do: from(transfer in __MODULE__, as: :transfer)

  def filter_by(queryable, :id, id), do: queryable |> where([transfer: t], t.id == ^id)

  def filter_by(queryable, :user_id, user_id),
    do: queryable |> where([transfer: t], t.user_id == ^user_id)

  def order_asc(queryable, :inserted_at),
    do: queryable |> order_by(asc: :inserted_at)

  def include(queryable, :source_playlist),
    do:
      queryable
      |> join(
        :left,
        [transfer: t],
        playlist in Playlist,
        on: t.source_playlist_id == playlist.id,
        as: :source_playlist
      )

  def include(queryable, :matching_job),
    do:
      queryable
      |> join(
        :left,
        [transfer: t],
        matching_job in Job,
        on: t.matching_step_job_id == matching_job.id,
        as: :matching_job
      )

  def include(queryable, :transfer_job),
    do:
      queryable
      |> join(
        :left,
        [transfer: t],
        transfer_job in Job,
        on: t.transfer_step_job_id == transfer_job.id,
        as: :transfer_job
      )

  def step(queryable, :matching, job_status),
    do:
      queryable
      |> where(
        [transfer: t, matching_job: mj],
        not is_nil(t.matching_step_job_id) and
          mj.status == ^job_status and
          is_nil(t.transfer_step_job_id)
      )

  def step(queryable, :transfer, job_status),
    do:
      queryable
      |> where(
        [transfer: t, matching_job: mj, transfer_job: tj],
        not is_nil(t.matching_step_job_id) and
          mj.status == :done and
          not is_nil(t.transfer_step_job_id) and
          tj.status == ^job_status
      )

  def sort_by(queryable, :inserted_at, :asc),
    do: queryable |> order_by(asc: :inserted_at)

  def sort_by(queryable, :inserted_at, :desc),
    do: queryable |> order_by(desc: :inserted_at)
end
