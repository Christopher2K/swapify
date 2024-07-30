defmodule SwapifyApi.MusicProviders.Spotify do
  @moduledoc "Interface to talk with Spotify"
  require Logger

  alias SwapifyApi.Utils
  alias SwapifyApi.Oauth
  alias SwapifyApi.Music.Track

  @account_url "https://accounts.spotify.com"
  @api_url "https://api.spotify.com/v1"

  @authentication_scope [
                          "playlist-read-private",
                          "playlist-read-collaborative",
                          "playlist-modify-private",
                          "playlist-modify-public",
                          "user-library-read",
                          "user-library-modify"
                        ]
                        |> Enum.join(" ")
  @redirect_uri "http://localhost:3000/api/integrations/spotify/callback"

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

  ## RESOURCES FUNCTIONS
  @spec get_user_library(String.t(), pos_integer(), pos_integer()) ::
          {:ok, list()} | {:error, atom()}
  def get_user_library(
        token,
        limit \\ 50,
        offset \\ 0
      ) do
    uri =
      get_api_url("/me/tracks", [
        {"limit", limit |> Integer.to_string()},
        {"offset", offset |> Integer.to_string()}
      ])

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

      {:ok, %Req.Response{status: 401} = response} ->
        {:error, response}

      {:ok, %Req.Response{status: 429} = response} ->
        {:error, response}

      {:error, exception} ->
        Logger.error(exception)
        {:error, :service_error}
    end
  end
end
