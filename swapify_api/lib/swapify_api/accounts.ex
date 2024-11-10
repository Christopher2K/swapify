defmodule SwapifyApi.Accounts do
  require Logger

  alias SwapifyApi.Accounts.PasswordResetRequest
  alias SwapifyApi.Accounts.PasswordResetRequestRepo
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Accounts.PlatformConnectionRepo
  alias SwapifyApi.Accounts.Token
  alias SwapifyApi.Accounts.User
  alias SwapifyApi.Accounts.UserRepo
  alias SwapifyApi.Emails
  alias SwapifyApi.MusicProviders
  alias SwapifyApi.MusicProviders.AppleMusic
  alias SwapifyApi.MusicProviders.AppleMusicTokenWorker
  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.Oauth

  @create_or_update_integration_spotify_opts_def NimbleOptions.new!(
                                                   user_id: [type: :string, required: true],
                                                   code: [type: :string, required: true],
                                                   remote_state: [type: :string, required: true],
                                                   session_state: [type: :string, required: true]
                                                 )
  @create_or_update_integration_applemusic_opts_def NimbleOptions.new!(
                                                      user_id: [type: :string, required: true],
                                                      token: [type: :string, required: true]
                                                    )
  @type create_or_update_integration_applemusic_opts() ::
          unquote(
            NimbleOptions.option_typespec(@create_or_update_integration_applemusic_opts_def)
          )
  @type create_or_update_integration_spotify_opts() ::
          unquote(NimbleOptions.option_typespec(@create_or_update_integration_spotify_opts_def))
  @doc """
  For Spotify:
  #{NimbleOptions.docs(@create_or_update_integration_spotify_opts_def)}

  For Apple music:
  #{NimbleOptions.docs(@create_or_update_integration_applemusic_opts_def)}
  """
  @spec create_or_update_integration(
          PlatformConnection.platform_name(),
          create_or_update_integration_spotify_opts()
          | create_or_update_integration_applemusic_opts()
        ) ::
          {:ok, PlatformConnection.t()} | {:error, ErrorMessage.t()}
  def create_or_update_integration(:spotify = name, opts) do
    NimbleOptions.validate!(opts, @create_or_update_integration_spotify_opts_def)

    code = Keyword.get(opts, :code)
    remote_state = Keyword.get(opts, :remote_state)
    session_state = Keyword.get(opts, :session_state)
    user_id = Keyword.get(opts, :user_id)

    with {:ok} <- Oauth.check_state(session_state, remote_state),
         {:ok, access_token_data} <- Spotify.request_access_token(code),
         {:ok, spotify_user, _} <- Spotify.get_user(access_token_data.access_token),
         {:ok, pc, operation_type} <-
           PlatformConnectionRepo.create_or_update(user_id, name, %{
             "access_token_exp" => access_token_data.expires_at,
             "access_token" => access_token_data.access_token,
             "refresh_token" => access_token_data.refresh_token,
             "country_code" => spotify_user["country"],
             "platform_id" => spotify_user["id"]
           }) do
      case operation_type do
        :created ->
          # When created for the first time we will try to synchronize the library data for this user
          MusicProviders.start_platform_sync(user_id, name)
          {:ok, pc}

        _ ->
          {:ok, pc}
      end
    end
  end

  def create_or_update_integration(:applemusic = name, opts) do
    NimbleOptions.validate!(opts, @create_or_update_integration_applemusic_opts_def)

    token = Keyword.get(opts, :token)
    user_id = Keyword.get(opts, :user_id)

    exp = DateTime.utc_now() |> DateTime.add(60, :day)

    with dev_token <- AppleMusicTokenWorker.get(),
         {:ok, storefront, _} <- AppleMusic.get_storefront(dev_token, token),
         {:ok, pc, operation_type} <-
           PlatformConnectionRepo.create_or_update(user_id, name, %{
             "country_code" => storefront["id"],
             "access_token_exp" => exp,
             "access_token" => token
           }) do
      case operation_type do
        :created ->
          # When created for the first time we will try to synchronize the library data for this user
          MusicProviders.start_platform_sync(user_id, name)
          {:ok, pc}

        _ ->
          {:ok, pc}
      end
    end
  end

  @access_token_validity 3600
  @refresh_token_validity 86400
  @doc """
  Generate an access and refresh token for a given user
  """
  @spec genereate_auth_tokens(User.t()) ::
          {:ok, User.t(), Joken.bearer_token(), Joken.bearer_token()} | {:error, ErrorMessage.t()}
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
      _ -> {:error, ErrorMessage.internal_server_error("An error occurred, please try again.")}
    end
  end

  @namespace "user_socket"
  @doc """
  Generate a socket token for a given user
  """
  @spec generate_socket_token(String.t()) :: {:ok, String.t()}
  def generate_socket_token(user_id) do
    secret =
      Keyword.get(Application.get_env(:swapify_api, SwapifyApiWeb.Endpoint), :secret_key_base)

    Phoenix.Token.sign(
      secret,
      @namespace,
      user_id
    )
    |> then(fn token -> {:ok, token} end)
  end

  @doc """
  Disable a partner integration
  """
  @spec disable_partner_integration(String.t(), PlatformConnection.platform_name()) ::
          {:ok, PlatformConnection.t()} | {:error, ErrorMessage.t()}
  def disable_partner_integration(user_id, platform_name) do
    case PlatformConnectionRepo.invalidate(user_id, platform_name) do
      {:error, _} ->
        {:error,
         ErrorMessage.bad_request(
           "Error while trying to disable an integration. Please try again."
         )}

      result ->
        result
    end
  end

  @doc """
  Refresh an existing partner integration
  """
  @spec refresh_partner_integration(String.t(), PlatformConnection.platform_name(), String.t()) ::
          {:ok, PlatformConnection.t()} | {:error, ErrorMessage.t()}
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
        disable_partner_integration(user_id, name)
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

  @spec is_login_authorized?(User.t()) :: :ok | {:error, ErrorMessage.t()}
  def is_login_authorized?(%User{} = u) do
    if u.role in [:admin, :beta] do
      :ok
    else
      {:error,
       ErrorMessage.forbidden(
         "You are not authorized to login during our closed beta. Come back later!"
       )}
    end
  end

  @doc """
  Sign in a user and generate an access and refresh token
  """
  @spec sign_in_user(String.t(), String.t()) ::
          {:ok, User.t(), Joken.bearer_token(), Joken.bearer_token()} | {:error, ErrorMessage.t()}
  def sign_in_user(email, password) do
    with {:ok, user} <- UserRepo.get_by(:email, email),
         true <- is_password_valid?(password, user.password),
         :ok <- is_login_authorized?(user),
         {:ok, _, _, _} = user_auth_data <- genereate_auth_tokens(user) do
      user_auth_data
    else
      {:error, %ErrorMessage{code: :forbidden}} = error ->
        error

      _ ->
        {:error, ErrorMessage.unauthorized("Invalid email or password.")}
    end
  end

  @doc """
  Sign up a new user
  Map properties: - username
  - email
  - password
  """
  @spec sign_up_new_user(map()) :: {:ok, User.t()} | {:error, Changeset.t()}
  def sign_up_new_user(registration_data) do
    with {:ok, user} <- UserRepo.create(registration_data) do
      Task.Supervisor.start_child(Task.Supervisor, fn ->
        SwapifyApi.Emails.welcome(user.email, user.username)
        |> SwapifyApi.Mailer.deliver()
      end)

      {:ok, user}
    else
      error -> error
    end
  end

  @max_age 60 * 60
  @namespace "user_socket"
  @doc """
  Validate a socket token for a given user
  """
  @spec validate_socket_token(String.t()) ::
          {:ok, String.t()} | {:error, ErrorMessage.t()}
  def validate_socket_token(token) do
    secret =
      Keyword.get(Application.get_env(:swapify_api, SwapifyApiWeb.Endpoint), :secret_key_base)

    case Phoenix.Token.verify(secret, @namespace, token, max_age: @max_age) do
      {:ok, user_id} -> {:ok, user_id}
      _ -> {:error, ErrorMessage.unauthorized("Invalid token.")}
    end
  end

  @doc """
  Get a user by id
  """
  @spec get_by_id(String.t()) :: {:ok, User.t()} | {:error, ErrorMessage.t()}
  def get_by_id(id), do: UserRepo.get_by(:id, id)

  @doc """
  Create a new password reset request
  """
  @spec create_new_password_reset_request(String.t()) ::
          {:ok, PasswordResetRequest.t()} | {:error, ErrorMessage.t()}
  def create_new_password_reset_request(user_email) do
    with {:ok, user} <- UserRepo.get_by(:email, user_email),
         {:ok, password_reset_request} <- PasswordResetRequestRepo.create(user.id),
         {:ok, _} <-
           Emails.password_reset_request(user.email, user.username,
             code: password_reset_request.code
           )
           |> SwapifyApi.Mailer.deliver() do
      {:ok, password_reset_request}
    end
  end

  @doc """
  Confirm a password reset request
  TODO: Make this live in a transaction
  """
  @spec confirm_password_reset_request(String.t(), String.t()) ::
          {:ok, User.t()} | {:error, ErrorMessage.t()}
  def confirm_password_reset_request(code, password) do
    with {:ok, password_reset_request} <- PasswordResetRequestRepo.get_by_code(code),
         {:is_valid, true} <- {:is_valid, PasswordResetRequest.is_valid?(password_reset_request)},
         {:ok, user} <- UserRepo.update(password_reset_request.user, %{"password" => password}) do
      case PasswordResetRequestRepo.mark_as_used(code) do
        {1, _} ->
          {:ok, user}

        error ->
          error
      end
    else
      {:is_valid, false} ->
        {:error, ErrorMessage.bad_request("The password reset request is no longer valid.")}

      {:error, %Ecto.Changeset{} = e} ->
        {:error, e}

      error ->
        error
    end
  end
end
