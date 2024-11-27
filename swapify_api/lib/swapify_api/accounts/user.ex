defmodule SwapifyApi.Accounts.User do
  use SwapifyApi.Schema, query_name: "user"

  alias SwapifyApi.Accounts.PlatformConnection

  @type user_role :: :beta | :user | :admin

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          username: String.t(),
          email: String.t(),
          password: String.t(),
          inserted_at: DateTime.t(),
          updated_at: DateTime.t(),
          role: user_role()
        }

  schema "users" do
    field :email, :string
    field :password, :string
    field :username, :string
    field :role, Ecto.Enum, values: [:beta, :user, :admin], default: :user
    has_many :platform_connections, PlatformConnection

    timestamps(type: :utc_datetime)
  end

  @doc "Default changeset"
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :username, :role])
    |> validate_required([:email, :password, :username])
    |> hash_new_password()
  end

  @doc "Changaset user to create a new user"
  def create_changeset(user, attrs) do
    user
    |> cast(attrs, [:email, :password, :username, :role])
    |> validate_required([:email, :password, :username])
    |> validate_format(:email, ~r/@/)
    |> validate_password()
    |> validate_length(:username, min: 3, max: 20)
    |> unique_constraint(:email, message: "Email is already taken")
    |> unique_constraint(:username, message: "Username is already taken")
    |> hash_new_password()
  end

  @doc "Changeset to update an existing user"
  def update_changeset(user, attrs) do
    user
    |> cast(attrs, [:password, :role])
    |> validate_required([:password])
    |> validate_password()
    |> hash_new_password()
  end

  defp validate_password(changeset), do: validate_length(changeset, :password, min: 8, max: 30)

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

  def queryable(), do: from(account in __MODULE__, as: :account)

  def filter_by(queryable, :id, value), do: where(queryable, [account: a], a.id == ^value)
  def filter_by(queryable, :email, value), do: where(queryable, [account: a], a.email == ^value)
end
