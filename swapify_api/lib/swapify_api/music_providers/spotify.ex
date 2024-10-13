defmodule SwapifyApi.MusicProviders.Spotify do
  @moduledoc "Interface to talk to Spotify"
  require Logger

  alias SwapifyApi.Tasks.MatchedTrack
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
                          "user-library-modify",
                          "user-read-private"
                        ]
                        |> Enum.join(" ")

  defp get_redirect_uri(),
    do:
      Application.fetch_env!(:swapify_api, :api_url) <>
        "/api/integrations/spotify/callback"

  defp get_client_id(), do: Application.fetch_env!(:swapify_api, __MODULE__)[:client_id]

  defp get_client_secret(),
    do: Application.fetch_env!(:swapify_api, __MODULE__)[:client_secret]

  defp get_api_url("/" <> _ = path, query_params \\ []) do
    uri = URI.parse(@api_url <> path)

    query_params
    |> Enum.reduce(uri, fn {key, val}, uri ->
      URI.append_query(uri, URI.encode(key <> "=" <> val))
    end)
    |> URI.to_string()
  end

  @spec handle_api_error({:ok, Req.Response.t()} | {:error, any()}, String.t()) ::
          SwapifyApi.Errors.t()
  defp handle_api_error(result, uri) do
    case result do
      {:ok, %Req.Response{} = response} ->
        Logger.error("API Service error",
          service: "spotify",
          uri: uri,
          status: response.status,
          response: response.body
        )

        SwapifyApi.Errors.http_service_error(response.status)

      {:error, exception} ->
        Logger.error("Failed to call an API",
          service: "spotify",
          uri: uri,
          error: exception
        )

        {:error, :service_error}
    end
  end

  ## AUTH FUNCTIONS
  @spec generate_auth_url(String.t()) :: String.t()
  def generate_auth_url(state) do
    client_id = get_client_id()

    query_params = [
      {"client_id", client_id},
      {"response_type", "code"},
      {"redirect_uri", get_redirect_uri()},
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
          {:ok, Oauth.AccessToken.t()} | SwapifyApi.Errors.t()
  def request_access_token(authorization_code) do
    body = %{
      "grant_type" => "authorization_code",
      "redirect_uri" => get_redirect_uri(),
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

      _ ->
        handle_api_error(result, uri)
    end
  end

  @doc "Refresh the access token of a user"
  @spec refresh_access_token(String.t()) ::
          {:ok, Oauth.AccessToken.t()} | SwapifyApi.Errors.t()
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

      _ ->
        handle_api_error(result, uri)
    end
  end

  ## RESOURCES FUNCTIONS

  @doc """
  See https://developer.spotify.com/documentation/web-api/reference/get-current-users-profile
  """
  @spec get_user(String.t()) ::
          {:ok, map(), Req.Response.t()} | SwapifyApi.Errors.t()
  def get_user(token) do
    uri = get_api_url("/me")

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
        {:ok, response.body, response}

      _ ->
        handle_api_error(result, uri)
    end
  end

  @spec get_user_library(String.t(), pos_integer(), pos_integer()) ::
          {:ok, list(), Req.Response.t()} | SwapifyApi.Errors.t()
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

      _ ->
        handle_api_error(result, uri)
    end
  end

  @spec search_track(String.t(), String.t()) ::
          {:ok, MatchedTrack.t() | nil, Req.Response.t()} | SwapifyApi.Errors.t()

  def search_track(
        token,
        %{
          "isrc" => isrc
        } = args
      )
      when is_nil(isrc) do
    search_track_by_infos(token, args)
  end

  def search_track(
        token,
        %{
          "isrc" => isrc
        } = args
      )
      when not is_nil(isrc) do
    case search_track_by_isrc(token, isrc) do
      {:ok, [], _} ->
        search_track_by_infos(token, args)

      result ->
        result
    end
  end

  defp search_track_by_isrc(token, isrc) do
    uri =
      get_api_url("/search", [
        {"offset", "0"},
        {"limit", "1"},
        {"type", "track"},
        {"q", "isrc:#{isrc}"}
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
        case response.body["tracks"]["items"] do
          [] ->
            {:ok, nil, response}

          [track | _] ->
            {:ok,
             %MatchedTrack{
               platform_link: track["href"],
               platform_id: track["id"],
               isrc: isrc
             }, response}
        end

      _ ->
        handle_api_error(result, uri)
    end
  end

  defp search_track_by_infos(token, %{
         "name" => name,
         "album" => album,
         "isrc" => isrc
       }) do
    uri =
      get_api_url("/search", [
        {"offset", "0"},
        {"limit", "1"},
        {"type", "track"},
        {"q", "album:#{album} track:#{name}"}
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
        case response.body["tracks"]["items"] do
          [] ->
            {:ok, nil, response}

          [track | _] ->
            {:ok,
             %MatchedTrack{
               platform_link: track["href"],
               platform_id: track["id"],
               isrc: isrc
             }, response}
        end

      _ ->
        handle_api_error(result, uri)
    end
  end

  @spec add_tracks_to_library(String.t(), list(String.t())) ::
          {:ok, Req.Response.t()} | SwapifyApi.Errors.t()
  def add_tracks_to_library(token, track_ids) do
    uri = get_api_url("/me/tracks")

    Logger.debug("Call API", service: "spotify", uri: uri)

    result =
      [
        method: :put,
        url: uri,
        headers: %{"authorization" => "Bearer #{token}"},
        json: %{"ids" => track_ids}
      ]
      |> Utils.prepare_request()
      |> Req.request()

    case result do
      {:ok, %Req.Response{status: 200} = resp} ->
        {:ok, resp}

      _ ->
        handle_api_error(result, uri)
    end
  end
end
