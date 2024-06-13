defmodule SwapifyApi.Accounts.PlatformConnection do
  use SwapifyApi.Schema

  import Ecto.Query

  alias SwapifyApi.Accounts.User

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          user_id: Ecto.UUID.t(),
          name: String.t(),
          access_token: String.t() | nil,
          access_token_exp: DateTime.t() | nil,
          refresh_token: String.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "platform_connections" do
    field :name, :string
    field :access_token, :string
    field :access_token_exp, :utc_datetime
    field :refresh_token, :string
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc "Default changeset"
  def changeset(platform_connection, attrs \\ %{}) do
    platform_connection
    |> cast(attrs, [:access_token, :access_token_exp, :refresh_token, :name, :user_id])
    |> validate_required([:access_token, :access_token_exp, :refresh_token, :name, :user_id])
  end

  def update_changeset(platform_connection, attrs \\ %{}) do
    platform_connection
    |> cast(attrs, [:access_token, :access_token_exp, :refresh_token])
    |> validate_required([:access_token, :access_token_exp, :refresh_token])
  end

  def queryable(), do: from(platform_connection in __MODULE__, as: :platform_connection)

  def filter_by(queryable, :user_id, value),
    do: where(queryable, [platform_connection: pt], pt.user_id == ^value)

  def filter_by(queryable, :name, value),
    do: where(queryable, [platform_connection: pt], pt.name == ^value)
end
