defmodule SwapifyApi.Accounts.Services.RefreshPartnerIntegration do
  @moduledoc "Refresh the access token of a partner integration"
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Accounts.PlatformConnectionRepo
  alias SwapifyApi.Accounts.Services.RemovePartnerIntegration
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.Oauth.AccessToken

  @spec call(String.t(), PlatformConnection.platform_name(), String.t()) ::
          {:ok, PlatformConnection.t()} | {:error, atom()}
  def call(user_id, :spotify = name, refresh_token) do
    with {:ok,
          %AccessToken{
            access_token: access_token,
            expires_at: expires_at
          }} <- Spotify.refresh_access_token(refresh_token),
         {:ok, updated_pc} <-
           PlatformConnectionRepo.create_or_update(user_id, name, %{
             "access_token" => access_token,
             "access_token_exp" => expires_at
           }) do
      {:ok, updated_pc}
    else
      {:error, _} ->
        RemovePartnerIntegration.call(user_id, name)
        {:error, :service_error}
    end
  end
end
