defmodule SwapifyApi.Accounts.PlatformConnection do
  use SwapifyApi.Schema

  alias SwapifyApi.Accounts.User

  @type platform_name :: :spotify | :applemusic

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          user_id: Ecto.UUID.t(),
          platform_id: String.t(),
          name: platform_name(),
          country_code: String.t() | nil,
          access_token: String.t() | nil,
          access_token_exp: DateTime.t() | nil,
          refresh_token: String.t() | nil,
          invalidated_at: DateTime.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "platform_connections" do
    field :platform_id, :string
    field :name, Ecto.Enum, values: [:spotify, :applemusic]
    field :country_code, :string
    field :access_token, :string
    field :access_token_exp, :utc_datetime
    field :refresh_token, :string
    field :invalidated_at, :utc_datetime
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end

  @doc "Default changeset"
  def changeset(platform_connection, attrs \\ %{}) do
    platform_connection
    |> cast(attrs, [
      :access_token,
      :access_token_exp,
      :refresh_token,
      :invalidated_at,
      :platform_id,
      :name,
      :user_id,
      :country_code
    ])
    |> validate_required([:access_token, :access_token_exp, :name, :user_id])
    |> unique_constraint([:platform_id, :name])
  end

  def create_changeset(platform_connection, attrs \\ %{}) do
    platform_connection
    |> cast(attrs, [
      :access_token,
      :access_token_exp,
      :refresh_token,
      :platform_id,
      :name,
      :user_id,
      :country_code
    ])
    |> validate_required([:access_token, :access_token_exp, :name, :user_id])
    |> unique_constraint([:platform_id, :name])
  end

  def update_changeset(platform_connection, attrs \\ %{}) do
    platform_connection
    |> cast(attrs, [:access_token, :access_token_exp, :refresh_token])
    |> put_change(:invalidated_at, nil)
    |> validate_required([:access_token, :access_token_exp])
  end

  def invalidate_changeset(platform_connection, attrs \\ %{}) do
    platform_connection
    |> cast(attrs, [:invalidated_at])
    |> validate_required([:invalidated_at])
  end

  # Queries
  def queryable(), do: from(platform_connection in __MODULE__, as: :platform_connection)

  def filter_by(queryable, :user_id, value),
    do: where(queryable, [platform_connection: pt], pt.user_id == ^value)

  def filter_by(queryable, :name, value),
    do: where(queryable, [platform_connection: pt], pt.name == ^value)

  def order_asc(queryable, :name),
    do: queryable |> order_by(asc: :name)

  # Functions

  @doc "Get the name of a platform"
  @spec get_name(platform_name()) :: String.t()
  def get_name(pc_name) do
    case pc_name do
      :spotify -> "Spotify"
      :applemusic -> "Apple Music"
    end
  end
end
