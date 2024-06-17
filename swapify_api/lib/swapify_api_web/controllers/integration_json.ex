defmodule SwapifyApiWeb.IntegrationJSON do
  def apple_music_login(%{token: token}) do
    %{"data" => %{"developerToken" => token}}
  end
end
