defmodule SwapifyApi.Accounts.User do
  use SwapifyApi.Schema, query_name: "user"

  import Ecto.Query

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

  @doc "Default changeset"
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> hash_new_password()
  end

  @doc "Changaset user to create a new user"
  def create_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8, max: 30)
    |> unique_constraint(:email)
    |> hash_new_password()
  end

  defp hash_new_password(changeset) do
    clear_password = get_change(changeset, :password)

    case clear_password do
      nil ->
        changeset

      pswd ->
        hash = SwapifyApi.Accounts.Services.UserPasswordHashing.hash(pswd)
        put_change(changeset, :password, hash)
    end
  end

  def queryable(), do: from(account in __MODULE__, as: :account)

  def filter_by(queryable, :id, value), do: where(queryable, [account: a], a.id == ^value)
  def filter_by(queryable, :email, value), do: where(queryable, [account: a], a.email == ^value)
end
