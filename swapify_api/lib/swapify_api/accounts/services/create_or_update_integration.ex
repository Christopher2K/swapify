defmodule SwapifyApi.Accounts.Services.CreateOrUpdateIntegration do
  require Logger

  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.Oauth
  alias SwapifyApi.Accounts.PlatformConnectionRepo

  @doc """
  Options:
  - :user_id - ID to use for the platform connection
  - :code - Authorization code we got from the provider
  - :remote_state - State we got from the provider
  - :session_state - State we kept in the session
  """
  def call("spotify" = name, opts \\ []) do
    user_id = Keyword.get(opts, :user_id)
    remote_state = Keyword.get(opts, :remote_state)
    session_state = Keyword.get(opts, :session_state)
    code = Keyword.get(opts, :code)

    with {:ok} <- Oauth.check_state(session_state, remote_state),
         {:ok, access_token_data} <- Spotify.request_access_token(code) do
      PlatformConnectionRepo.create_or_update(user_id, name, %{
        "access_token" => access_token_data.access_token,
        "refresh_token" => access_token_data.refresh_token
      })
    else
      {:error, %Ecto.Changeset{}} ->
        {:error, :server_error}

      {:error} ->
        {:error, :state_mismatch}

      error ->
        Logger.error(error)
        {:error, :service_error}
    end
  end

  # def call("applemusic", opts \\ []) do
  #
  # end
end
