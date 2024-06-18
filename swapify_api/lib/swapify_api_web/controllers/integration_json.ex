defmodule SwapifyApiWeb.IntegrationJSON do
  alias SwapifyApi.Accounts.PlatformConnection

  def index(%{platform_connections: platform_connections}) do
    %{"data" => platform_connections |> Enum.map(&PlatformConnection.to_json/1)}
  end

  def apple_music_login(%{token: token}) do
    %{"data" => %{"developerToken" => token}}
  end
end
