defmodule SwapifyApi.Accounts.Services.RefreshPartnerIntegration do
  @moduledoc "Refresh the access token of a partner integration"
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Accounts.PlatformConnectionRepo
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.Oauth.AccessToken

  @spec call(PlatformConnection.t()) :: {:ok, PlatformConnection.t()} | {:error, atom()}
  def call(%PlatformConnection{name: "spotify"} = pc) do
    with {:ok,
          %AccessToken{
            access_token: access_token,
            expires_at: expires_at
          }} <- Spotify.refresh_access_token(pc.refresh_token),
         {:ok, updated_pc} <-
           PlatformConnectionRepo.create_or_update(pc.user_id, pc.name, %{
             "access_token" => access_token,
             "access_token_exp" => expires_at
           }) do
      {:ok, updated_pc}
    else
      {:error, _} ->
        PlatformConnectionRepo.delete(pc.user_id, pc.name)
        {:error, :service_error}
    end
  end
end
