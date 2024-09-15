defmodule SwapifyApi.Tasks.Job do
  use SwapifyApi.Schema

  alias SwapifyApi.Accounts.User

  @type job_status :: :started | :done | :error

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          name: String.t(),
          status: job_status(),
          user_id: Ecto.UUID.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "jobs" do
    field :name, :string
    field :status, Ecto.Enum, values: [:started, :done, :error]
    field :oban_job_args, :map
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc "Default changeset"
  def changeset(job, attrs \\ %{}),
    do:
      job
      |> cast(attrs, [
        :name,
        :status,
        :user_id,
        :oban_job_args
      ])
      |> assoc_constraint(:user)
      |> validate_required([
        :name,
        :status,
        :user_id,
        :oban_job_args
      ])

  def queryable(), do: from(job in __MODULE__, as: :job)

  def filter_by(queryable, :id, value), do: where(queryable, [job: j], j.id == ^value)

  def filter_by(queryable, :name, value), do: where(queryable, [job: j], j.name == ^value)

  def filter_by(queryable, :user_id, value), do: where(queryable, [job: j], j.user_id == ^value)

  def has_started(queryable), do: where(queryable, [job: j], j.status == :started)

  def is_done(queryable), do: where(queryable, [job: j], j.status == :done)
end
