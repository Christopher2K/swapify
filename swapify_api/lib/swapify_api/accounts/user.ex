defmodule SwapifyApi.Accounts.User do
  use SwapifyApi.Schema, query_name: "user"

  alias SwapifyApi.Accounts.PlatformConnection

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          username: String.t(),
          email: String.t(),
          password: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "users" do
    field :email, :string
    field :password, :string
    field :username, :string
    has_many :platform_connections, PlatformConnection

    timestamps(type: :utc_datetime)
  end

  @doc "Default changeset"
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :username])
    |> validate_required([:email, :password, :username])
    |> hash_new_password()
  end

  @doc "Changaset user to create a new user"
  def create_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :username])
    |> validate_required([:email, :password, :username])
    |> validate_format(:email, ~r/@/)
    |> validate_length(:password, min: 8, max: 30)
    |> validate_length(:username, min: 3, max: 20)
    |> unique_constraint(:email, message: "Email is already taken")
    |> unique_constraint(:username, message: "Username is already taken")
    |> hash_new_password()
  end

  defp hash_new_password(changeset) do
    clear_password = get_change(changeset, :password)

    case clear_password do
      nil ->
        changeset

      pswd ->
        hash = SwapifyApi.Accounts.hash_password(pswd)
        put_change(changeset, :password, hash)
    end
  end

  def to_map(%__MODULE__{} = user),
    do: %{
      "id" => user.id,
      "username" => user.username,
      "email" => user.email,
      "insertedAt" => user.inserted_at,
      "updatedAt" => user.updated_at
    }

  def queryable(), do: from(account in __MODULE__, as: :account)

  def filter_by(queryable, :id, value), do: where(queryable, [account: a], a.id == ^value)
  def filter_by(queryable, :email, value), do: where(queryable, [account: a], a.email == ^value)
end
