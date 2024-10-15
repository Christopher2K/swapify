defmodule SwapifyApi.Accounts.PlatformConnection do
  use SwapifyApi.Schema

  alias SwapifyApi.Accounts.User

  @type platform_name :: :spotify | :applemusic

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          user_id: Ecto.UUID.t(),
          name: platform_name(),
          country_code: String.t() | nil,
          access_token: String.t() | nil,
          access_token_exp: DateTime.t() | nil,
          refresh_token: String.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "platform_connections" do
    field :name, Ecto.Enum, values: [:spotify, :applemusic]
    field :country_code, :string
    field :access_token, :string
    field :access_token_exp, :utc_datetime
    field :refresh_token, :string
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  def to_json(platform_connection),
    do: %{
      "id" => platform_connection.id,
      "name" => platform_connection.name,
      "countryCode" => platform_connection.country_code,
      "accessTokenExp" => platform_connection.access_token_exp,
      "userId" => platform_connection.user_id
    }

  @doc "Default changeset"
  def changeset(platform_connection, attrs \\ %{}) do
    platform_connection
    |> cast(attrs, [
      :access_token,
      :access_token_exp,
      :refresh_token,
      :name,
      :user_id,
      :country_code
    ])
    |> validate_required([:access_token, :access_token_exp, :name, :user_id])
  end

  def update_changeset(platform_connection, attrs \\ %{}) do
    platform_connection
    |> cast(attrs, [:access_token, :access_token_exp, :refresh_token])
    |> validate_required([:access_token, :access_token_exp])
  end

  def queryable(), do: from(platform_connection in __MODULE__, as: :platform_connection)

  def filter_by(queryable, :user_id, value),
    do: where(queryable, [platform_connection: pt], pt.user_id == ^value)

  def filter_by(queryable, :name, value),
    do: where(queryable, [platform_connection: pt], pt.name == ^value)

  def order_asc(queryable, :name),
    do: queryable |> order_by(asc: :name)
end
