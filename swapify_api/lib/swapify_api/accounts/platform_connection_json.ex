defmodule SwapifyApi.Accounts.PlatformConnectionJSON do
  @moduledoc "PlatformConnection json representations"

  alias SwapifyApi.Accounts.PlatformConnection

  def show(%PlatformConnection{} = platform_connection) do
    %{
      "id" => platform_connection.id,
      "name" => platform_connection.name,
      "countryCode" => platform_connection.country_code,
      "accessTokenExp" => platform_connection.access_token_exp,
      "invalidatedAt" => platform_connection.invalidated_at,
      "userId" => platform_connection.user_id
    }
  end

  def show(_), do: nil

  def list(pc_list), do: pc_list |> Enum.map(&show/1)
end
