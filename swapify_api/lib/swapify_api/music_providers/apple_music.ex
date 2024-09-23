defmodule SwapifyApi.MusicProviders.AppleMusic do
  @moduledoc "Interfact to talk to Apple Music"
  require Logger

  alias SwapifyApi.Utils
  alias SwapifyApi.MusicProviders.Track

  @api_url "https://api.music.apple.com/v1"
  @default_resource_limit 100
  @default_storefront "us"

  defp get_api_url("/" <> _ = path, query_params) do
    uri = URI.parse(@api_url <> path)

    query_params
    |> Enum.reduce(uri, fn {key, val}, uri ->
      URI.append_query(uri, URI.encode(key <> "=" <> val))
    end)
    |> URI.to_string()
  end

  defp handle_api_error(result, uri) do
    case result do
      {:ok, %Req.Response{} = response} ->
        Logger.error("API Service error",
          service: "applemusic",
          uri: uri,
          status: response.status,
          response: response.body
        )

        {:error, response.status, response}

      {:error, exception} ->
        Logger.error("Failed to call an API",
          service: "applemusic",
          uri: uri,
          error: exception
        )

        {:error, :service_error}
    end
  end

  ## RESOURCES FUNCTIONS
  @spec get_user_library(String.t(), String.t(), pos_integer(), pos_integer()) ::
          {:ok, list(), Req.Response.t()}
          | {:error, atom()}
          | {:error, pos_integer(), Req.Response.t()}
  def get_user_library(developer_token, user_token, offset \\ 0, limit \\ @default_resource_limit) do
    uri =
      get_api_url("/me/library/songs", [
        {"limit", limit |> Integer.to_string()},
        {"offset", offset |> Integer.to_string()},
        {"include", "catalog"}
      ])

    Logger.debug("Call API", service: "applemusic", uri: uri)

    result =
      [
        method: :get,
        url: uri,
        headers: %{
          "Authorization" => "Bearer #{developer_token}",
          "Music-User-Token" => user_token
        }
      ]
      |> Utils.prepare_request()
      |> Req.request()

    case result do
      {:ok, %Req.Response{status: 200} = response} ->
        tracks =
          response.body["data"]
          |> Enum.map(fn user_lib_item ->
            Track.from_apple_music_track(user_lib_item)
          end)

        {:ok, tracks, response}

      _ ->
        handle_api_error(result, uri)
    end
  end

  @spec search_tracks(String.t(), String.t(), list(String.t())) ::
          {:ok, map(), Req.Response.t()}
          | {:error, pos_integer(), Req.Response.t()}
          | {:error, any()}
  def search_tracks(developer_token, user_token, track_isrc_list) do
    uri =
      get_api_url(
        "/catalog/#{@default_storefront}/songs",
        [{"filter[isrc]", Enum.join(track_isrc_list, ",")}]
      )

    Logger.debug("Call API", service: "applemusic", uri: uri)

    result =
      [
        method: :get,
        url: uri,
        headers: %{
          "Authorization" => "Bearer #{developer_token}",
          "Music-User-Token" => user_token
        }
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

  @spec add_track_to_library(String.t(), String.t(), String.t()) ::
          {:ok, Req.Response.t()}
          | {:error, atom()}
          | {:error, pos_integer(), Req.Response.t()}
  def add_track_to_library(developer_token, user_token, track_id) do
    uri =
      get_api_url("/me/library", [
        {"ids[songs]", track_id}
      ])

    Logger.debug("Call API", service: "applemusic", uri: uri)

    result =
      [
        method: :post,
        url: uri,
        headers: %{
          "Authorization" => "Bearer #{developer_token}",
          "Music-User-Token" => user_token
        }
      ]
      |> Utils.prepare_request()
      |> Req.request()

    case result do
      {:ok, %Req.Response{status: 202} = response} ->
        {:ok, response}

      _ ->
        handle_api_error(result, uri)
    end
  end
end
