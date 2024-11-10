defmodule SwapifyApi.Accounts.PasswordResetRequest do
  use SwapifyApi.Schema

  alias SwapifyApi.Accounts.User

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          user_id: Ecto.UUID.t(),
          code: String.t(),
          is_used: boolean(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "password_reset_requests" do
    field :code, Ecto.Nanoid, autogenerate: true
    field :is_used, :boolean, default: false
    belongs_to :user, User
    timestamps(type: :utc_datetime)
  end

  @doc "Default changeset"
  def changeset(password_reset_request, attrs \\ %{}),
    do:
      password_reset_request
      |> cast(attrs, [:user_id, :is_used, :inserted_at])
      |> validate_required([:user_id])

  def create_changeset(password_reset_request, attrs \\ %{}) do
    password_reset_request
    |> cast(attrs, [:user_id])
    |> validate_required([:user_id])
  end

  @request_lifetime_ms :timer.hours(1)
  def is_valid?(%__MODULE__{} = pr) do
    now = DateTime.utc_now()
    seconds = @request_lifetime_ms |> Integer.floor_div(1000)

    is_expired? = DateTime.add(pr.inserted_at, seconds, :second) < now

    not is_expired? && not pr.is_used
  end
end
