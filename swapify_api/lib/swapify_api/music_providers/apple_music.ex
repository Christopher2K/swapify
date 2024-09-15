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

  ## RESOURCES FUNCTIONS
  @spec get_user_library(String.t(), String.t(), pos_integer(), pos_integer()) ::
          {:ok, list(), Req.Response.t()}
          | {:error, atom()}
          | {:error, pos_integer(), Req.Response.t()}
  def get_user_library(developer_token, user_token, offset \\ 0, limit \\ @default_resource_limit) do
    Logger.debug("start: get_user_library/3", offset: offset, limit: limit)

    uri =
      get_api_url("/me/library/songs", [
        {"limit", limit |> Integer.to_string()},
        {"offset", offset |> Integer.to_string()},
        {"include", "catalog"}
      ])

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
        Logger.debug("success: get_user_library/3 - response: #{response.status}")

        tracks =
          response.body["data"]
          |> Enum.map(fn user_lib_item ->
            Track.from_apple_music_track(user_lib_item)
          end)

        {:ok, tracks, response}

      {:ok, %Req.Response{status: 401} = response} ->
        Logger.debug("error: get_user_library/3 - response: #{response.status}")
        {:error, 401, response}

      {:ok, %Req.Response{status: 429} = response} ->
        Logger.debug("error: get_user_library/3 - response: #{response.status}")
        {:error, 429, response}

      {:error, exception} ->
        Logger.debug("service error: get_user_library/3", error: exception)
        {:error, :service_error}
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

      {:ok, response} ->
        {:error, response.status, response}

      error ->
        error
    end
  end
end
