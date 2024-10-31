defmodule SwapifyApiWeb.IntegrationJSON do
  alias SwapifyApi.Accounts.PlatformConnectionJSON

  def index(%{platform_connections: platform_connections}),
    do: %{"data" => PlatformConnectionJSON.list(platform_connections)}

  def apple_music_login(%{token: token}), do: %{"data" => %{"developerToken" => token}}
end
