defmodule SwapifyApi.Accounts do
  require Logger

  alias SwapifyApi.Accounts.UserRepo
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Accounts.PlatformConnectionRepo
  alias SwapifyApi.Accounts.Token
  alias SwapifyApi.Accounts.User
  alias SwapifyApi.MusicProviders.AppleMusic
  alias SwapifyApi.MusicProviders.AppleMusicTokenWorker
  alias SwapifyApi.MusicProviders.Services.StartPlatformSync
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.Oauth
  alias SwapifyApi.Utils

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
          {:ok, User.t(), Joken.bearer_token(), Joken.bearer_token()} | SwapifyApi.Errors.t()
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

  @namespace "user_socket"
  @doc """
  Generate a socket token for a given user
  """
  @spec generate_socket_token(String.t()) :: {:ok, String.t()} | SwapifyApi.Errors.t()
  def generate_socket_token(user_id) do
    secret =
      Keyword.get(Application.get_env(:swapify_api, SwapifyApiWeb.Endpoint), :secret_key_base)

    Phoenix.Token.sign(
      secret,
      @namespace,
      user_id
    )
    |> Utils.from_nullable_to_tuple()
  end

  @doc """
  Remove a partner integration
  """
  @spec remove_partner_integration(String.t(), PlatformConnection.platform_name()) :: {:ok}
  def remove_partner_integration(user_id, platform_name) do
    PlatformConnectionRepo.delete(user_id, platform_name)
  end

  @spec refresh_partner_integration(String.t(), PlatformConnection.platform_name(), String.t()) ::
          {:ok, PlatformConnection.t()} | SwapifyApi.Errors.t()
  def refresh_partner_integration(user_id, :spotify = name, refresh_token) do
    with {:ok,
          %Oauth.AccessToken{
            access_token: access_token,
            expires_at: expires_at
          }} <- Spotify.refresh_access_token(refresh_token),
         {:ok, updated_pc, :updated} <-
           PlatformConnectionRepo.create_or_update(user_id, name, %{
             "access_token" => access_token,
             "access_token_exp" => expires_at
           }) do
      {:ok, updated_pc}
    else
      _ ->
        # TODO: Do not remove the integration on error, just disable it so the user know there's something wrong
        remove_partner_integration(user_id, name)
        {:error, :service_error}
    end
  end

  @doc """
  Hash a password
  """
  @spec hash_password(String.t()) :: String.t()
  def hash_password(password), do: Argon2.hash_pwd_salt(password)

  @doc """
  Verify a password
  """
  @spec is_password_valid?(String.t(), String.t()) :: boolean()
  def is_password_valid?(password_input, hash), do: Argon2.verify_pass(password_input, hash)

  @doc """
  Sign in a user and generate an access and refresh token
  """
  @spec sign_in_user(String.t(), String.t()) ::
          {:ok, User.t(), Joken.bearer_token(), Joken.bearer_token()} | SwapifyApi.Errors.t()
  def sign_in_user(email, password) do
    with {:ok, user} <- UserRepo.get_by(:email, email),
         true <- is_password_valid?(password, user.password),
         {:ok, _, _, _} = user_auth_data <- genereate_auth_tokens(user) do
      user_auth_data
    else
      _ ->
        SwapifyApi.Errors.auth_failed()
    end
  end

  @doc """
  Sign up a new user
  Map properties:
  - username
  - email
  - password
  """
  @spec sign_up_new_user(map()) :: {:ok, User.t()} | SwapifyApi.Errors.t()
  def sign_up_new_user(registration_data),
    # TODO: Email on registration
    do: UserRepo.create(registration_data)
end
