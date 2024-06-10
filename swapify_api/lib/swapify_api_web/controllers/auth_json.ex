defmodule SwapifyApiWeb.AuthJSON do
  alias SwapifyApi.Accounts.User

  def signin(%{access_token: access_token, refresh_token: refresh_token, user: user}) do
    %{
      "data" => %{
        "accessToken" => access_token,
        "refreshToken" => refresh_token,
        "user" => User.to_map(user)
      }
    }
  end
end
