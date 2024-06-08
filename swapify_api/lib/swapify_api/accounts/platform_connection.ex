defmodule SwapifyApi.Accounts.PlatformConnection do
  use SwapifyApi.Schema

  alias SwapifyApi.Accounts.User

  @type t :: %__MODULE__{
          id: Ecto.UUID.t(),
          user_id: Ecto.UUID.t(),
          name: String.t(),
          access_token: String.t() | nil,
          refresh_token: String.t() | nil,
          inserted_at: DateTime.t(),
          updated_at: DateTime.t()
        }

  schema "platform_connections" do
    field :name, :string
    field :access_token, :string
    field :refresh_token, :string
    belongs_to :user, User

    timestamps(type: :utc_datetime)
  end
end
