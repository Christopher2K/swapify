defmodule SwapifyApi.Accounts.User do
  use SwapifyApi.Schema

  alias SwapifyApi.Accounts.PlatformConnection

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          email: String.t(),
          password: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "users" do
    field :password, :string
    field :email, :string
    has_many :platform_connections, PlatformConnection

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
  end
end
