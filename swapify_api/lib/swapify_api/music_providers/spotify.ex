defmodule SwapifyApi.MusicProviders.Spotify do
  @moduledoc "Interface to talk to Spotify"
  require Logger

  alias SwapifyApi.Utils
  alias SwapifyApi.Oauth
  alias SwapifyApi.MusicProviders.Track

  @account_url "https://accounts.spotify.com"
  @api_url "https://api.spotify.com/v1"
  @default_resource_limit 50

  @authentication_scope [
                          "playlist-read-private",
                          "playlist-read-collaborative",
                          "playlist-modify-private",
                          "playlist-modify-public",
                          "user-library-read",
                          "user-library-modify"
                        ]
                        |> Enum.join(" ")
  @redirect_uri "http://localhost:4000/api/integrations/spotify/callback"

  defp get_client_id(), do: Application.fetch_env!(:swapify_api, __MODULE__)[:client_id]

  defp get_client_secret(),
    do: Application.fetch_env!(:swapify_api, __MODULE__)[:client_secret]

  defp get_api_url("/" <> _ = path, query_params) do
    uri = URI.parse(@api_url <> path)

    query_params
    |> Enum.reduce(uri, fn {key, val}, uri ->
      URI.append_query(uri, URI.encode(key <> "=" <> val))
    end)
    |> URI.to_string()
  end

  ## AUTH FUNCTIONS
  @spec generate_auth_url(String.t()) :: String.t()
  def generate_auth_url(state) do
    client_id = get_client_id()

    query_params = [
      {"client_id", client_id},
      {"response_type", "code"},
      {"redirect_uri", @redirect_uri},
      {"scope", @authentication_scope},
      {"state", state}
    ]

    uri = URI.parse(@account_url <> "/authorize")

    query_params
    |> Enum.reduce(uri, fn {key, val}, uri ->
      URI.append_query(uri, URI.encode(key <> "=" <> val))
    end)
    |> URI.to_string()
  end

  @spec request_access_token(String.t()) ::
          {:ok, Oauth.AccessToken.t()} | {:error, Req.Response.t() | atom()}
  def request_access_token(authorization_code) do
    body = %{
      "grant_type" => "authorization_code",
      "redirect_uri" => @redirect_uri,
      "code" => authorization_code
    }

    client_id = get_client_id()
    client_secret = get_client_secret()
    token = "#{client_id}:#{client_secret}" |> Base.encode64()

    uri = @account_url <> "/api/token"

    result =
      [
        method: :post,
        url: uri,
        headers: %{"authorization" => "Basic #{token}"},
        form: body
      ]
      |> Utils.prepare_request()
      |> Req.request()

    case result do
      {:ok, %Req.Response{status: 200} = response} ->
        result = response.body |> Oauth.AccessToken.from_map()
        {:ok, result}

      {:ok, %Req.Response{} = response} ->
        {:error, response}

      {:error, exception} ->
        Logger.error(exception)
        {:error, :service_error}
    end
  end

  @doc "Refresh the access token of a user"
  @spec refresh_access_token(String.t()) ::
          {:ok, Oauth.AccessToken.t()} | {:error, Req.Response.t() | atom()}
  def refresh_access_token(refresh_token) do
    uri = @account_url <> "/api/token"
    client_id = get_client_id()
    auth_header = "#{client_id}:#{get_client_secret()}" |> Base.encode64()

    body = %{
      "grant_type" => "refresh_token",
      "refresh_token" => refresh_token,
      "client_id" => client_id
    }

    result =
      [
        method: :post,
        url: uri,
        headers: %{"authorization" => "Basic #{auth_header}"},
        form: body
      ]
      |> Utils.prepare_request()
      |> Req.request()

    case result do
      {:ok, %Req.Response{status: 200} = response} ->
        result =
          response.body
          |> Map.put("refresh_token", refresh_token)
          |> Oauth.AccessToken.from_map()

        {:ok, result}

      {:ok, response} ->
        Logger.error("Failed to call an API",
          service: "spotify",
          uri: uri,
          status: response.status,
          response: response.body
        )

        {:error, response}

      {:error, exception} ->
        Logger.error("Failed to call an API",
          service: "spotify",
          uri: uri,
          error: exception
        )

        {:error, :service_error}
    end
  end

  ## RESOURCES FUNCTIONS
  @spec get_user_library(String.t(), pos_integer(), pos_integer()) ::
          {:ok, list(), Req.Response.t()}
          | {:error, atom()}
          | {:error, pos_integer(), Req.Response.t()}
  def get_user_library(
        token,
        offset \\ 0,
        limit \\ @default_resource_limit
      ) do
    uri =
      get_api_url("/me/tracks", [
        {"limit", limit |> Integer.to_string()},
        {"offset", offset |> Integer.to_string()}
      ])

    Logger.debug("Call API", service: "spotify", uri: uri)

    result =
      [
        method: :get,
        url: uri,
        headers: %{"authorization" => "Bearer #{token}"}
      ]
      |> Utils.prepare_request()
      |> Req.request()

    case result do
      {:ok, %Req.Response{status: 200} = response} ->
        tracks =
          response.body["items"]
          |> Enum.map(fn user_lib_item ->
            Track.from_spotify_track(user_lib_item["track"])
          end)

        {:ok, tracks, response}

      {:ok, %Req.Response{} = response} ->
        Logger.error("API Service error",
          service: "spotify",
          uri: uri,
          status: response.status,
          response: response.body
        )

        {:error, response.status, response}

      {:error, exception} ->
        Logger.error("Failed to call an API",
          service: "spotify",
          uri: uri,
          error: exception
        )

        {:error, :service_error}
    end
  end
end
