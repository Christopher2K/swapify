defmodule SwapifyApi.Accounts do
  require Logger

  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Accounts.PlatformConnectionRepo
  alias SwapifyApi.Accounts.Token
  alias SwapifyApi.Accounts.User
  alias SwapifyApi.MusicProviders.AppleMusic
  alias SwapifyApi.MusicProviders.AppleMusicTokenWorker
  alias SwapifyApi.MusicProviders.Services.StartPlatformSync
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.Oauth

  @doc """
  Options:
  - :user_id - ID to use for the platform connection

  For Spotify:
  - :code - Authorization code we got from the provider
  - :remote_state - State we got from the provider
  - :session_state - State we kept in the session

  For Apple music:
  - :token - Token code we got from AppleMusicKit on frontend
  """
  @spec create_or_update_integration(PlatformConnection.platform_name(), Keyword.t()) ::
          {:ok, map()} | SwapifyApi.Errors.t() | Ecto.Changeset.t()

  def create_or_update_integration(:spotify = name, opts) do
    Keyword.validate!(opts, [:user_id, :code, :remote_state, :session_state])

    user_id = Keyword.get(opts, :user_id)
    remote_state = Keyword.get(opts, :remote_state)
    session_state = Keyword.get(opts, :session_state)
    code = Keyword.get(opts, :code)

    with {:ok} <- Oauth.check_state(session_state, remote_state),
         {:ok, access_token_data} <- Spotify.request_access_token(code),
         {:ok, spotify_user, _} <- Spotify.get_user(access_token_data.access_token),
         {:ok, pc, operation_type} <-
           PlatformConnectionRepo.create_or_update(user_id, name, %{
             "access_token_exp" => access_token_data.expires_at,
             "access_token" => access_token_data.access_token,
             "refresh_token" => access_token_data.refresh_token,
             "country_code" => spotify_user["country"]
           }) do
      if operation_type == :created do
        # When created for the first time we will try to synchronize the library data for this user
        StartPlatformSync.call(user_id, name)
      end

      {:ok, pc}
    end
  end

  def create_or_update_integration(:applemusic = name, opts) do
    Keyword.validate!(opts, [:user_id, :token])

    user_id = Keyword.get(opts, :user_id)
    token = Keyword.get(opts, :token)
    exp = DateTime.utc_now() |> DateTime.add(60, :day)

    with dev_token <- AppleMusicTokenWorker.get(),
         {:ok, storefront, _} <- AppleMusic.get_storefront(dev_token, token),
         {:ok, pc, operation_type} <-
           PlatformConnectionRepo.create_or_update(user_id, name, %{
             "country_code" => storefront["id"],
             "access_token_exp" => exp,
             "access_token" => token
           }) do
      if operation_type == :created do
        # When created for the first time we will try to synchronize the library data for this user
        StartPlatformSync.call(user_id, name)
      end

      {:ok, pc}
    end
  end

  @access_token_validity 3600
  @refresh_token_validity 86400
  @doc """
  Generate an access and refresh token for a given user
  """
  @spec genereate_auth_tokens(User.t()) ::
          {:ok, User.t(), Joken.bearer_token(), Joken.bearer_token()}
  def genereate_auth_tokens(user) do
    now = DateTime.utc_now() |> DateTime.to_unix()

    claims = %{
      "access" => %{
        "iat" => now,
        "exp" => now + @access_token_validity,
        "user_id" => user.id,
        "user_email" => user.email
      },
      "refresh" => %{
        "iat" => now,
        "exp" => now + @refresh_token_validity,
        "user_id" => user.id,
        "user_email" => user.email
      }
    }

    with {:ok, access_token, _} <- Token.generate_and_sign(claims["access"]),
         {:ok, refresh_token, _} <- Token.generate_and_sign(claims["refresh"]) do
      {:ok, user, access_token, refresh_token}
    else
      {:error, _} -> SwapifyApi.Errors.server_error()
    end
  end
end
