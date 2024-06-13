defmodule SwapifyApi.Oauth.AccessToken do
  @moduledoc "Representation of a provider access token data"

  @enforce_keys [:access_token, :refresh_token, :expires_at]
  defstruct access_token: nil, refresh_token: nil, expires_at: nil

  @type t() :: %__MODULE__{
          access_token: String.t(),
          refresh_token: String.t(),
          expires_at: DateTime.t()
        }

  def from_map(%{
        "access_token" => access_token,
        "refresh_token" => refresh_token,
        "expires_in" => expires_in
      }) do
    %__MODULE__{
      access_token: access_token,
      refresh_token: refresh_token,
      expires_at: DateTime.utc_now() |> DateTime.add(second: expires_in)
    }
  end
end
