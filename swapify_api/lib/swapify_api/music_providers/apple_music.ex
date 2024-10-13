defmodule SwapifyApi.MusicProviders.AppleMusic do
  @moduledoc "Interfact to talk to Apple Music"
  require Logger

  alias SwapifyApi.Tasks.MatchedTrack
  alias SwapifyApi.Utils
  alias SwapifyApi.MusicProviders.Track

  @api_url "https://api.music.apple.com/v1"
  @default_resource_limit 100
  @default_storefront "us"

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
          service: "applemusic",
          uri: uri,
          status: response.status,
          response: response.body
        )

        SwapifyApi.Errors.http_service_error(response.status)

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
  @spec get_storefront(String.t(), String.t()) ::
          {:ok, map() | nil, Req.Response.t()} | SwapifyApi.Errors.t()
  def get_storefront(developer_token, user_token) do
    uri = get_api_url("/me/storefront")

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
        {:ok, Enum.at(response.body["data"], 0), response}

      _ ->
        handle_api_error(result, uri)
    end
  end

  @spec get_user_library(String.t(), String.t(), pos_integer(), pos_integer()) ::
          {:ok, list(), Req.Response.t()} | SwapifyApi.Errors.t()
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
          {:ok, map(), Req.Response.t()} | SwapifyApi.Errors.t()
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

  @doc """
  Search for one track on Apple Music
  Try a isrc match first, fallback on classic search when isrc is missing / not found
  Args map is expected to contain string keys:
  - "isrc"
  - "name"
  - "artist"
  - "album"
  """
  @spec search_track(String.t(), String.t(), map()) ::
          {:ok, MatchedTrack.t(), Req.Response.t()} | SwapifyApi.Errors.t()
  def search_track(
        developer_token,
        user_token,
        %{
          "isrc" => isrc
        } = args
      )
      when is_nil(isrc) do
    search_track_by_info(developer_token, user_token, args)
  end

  def search_track(
        developer_token,
        user_token,
        args
      ) do
    case search_track_by_isrc(developer_token, user_token, args) do
      {:ok, nil, _} -> search_track_by_info(developer_token, user_token, args)
      result -> result
    end
  end

  defp search_track_by_isrc(developer_token, user_token, %{
         "isrc" => isrc
       }) do
    uri =
      get_api_url(
        "/catalog/#{@default_storefront}/songs",
        [{"filter[isrc]", isrc}]
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
        case response.body["meta"]["filters"]["isrc"][isrc] do
          [%{"id" => id, "href" => href} | _] ->
            {:ok,
             %MatchedTrack{
               isrc: isrc,
               platform_id: id,
               platform_link: href
             }, response}

          _ ->
            {:ok, nil, response}
        end

      _ ->
        handle_api_error(result, uri)
    end
  end

  defp search_track_by_info(developer_token, user_token, %{
         "name" => name,
         "artist" => artist,
         "album" => album,
         "isrc" => isrc
       }) do
    uri =
      get_api_url(
        "/catalog/#{@default_storefront}/search",
        [
          {"types", "songs"},
          {"term",
           [name, artist, album]
           |> Enum.map(fn term ->
             String.replace(term, ~r/[\p{P}\p{S}]/, "")
           end)
           |> Enum.map(fn term -> String.replace(term, " ", "+") end)
           |> Enum.join("+")}
        ]
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
        case response.body["results"]["songs"]["data"] do
          [
            %{
              "id" => id,
              "href" => href
            }
            | _
          ] ->
            {:ok,
             %MatchedTrack{
               isrc: isrc,
               platform_id: id,
               platform_link: href
             }, response}

          _ ->
            {:ok, nil, response}
        end

      _ ->
        handle_api_error(result, uri)
    end
  end

  @spec add_track_to_library(String.t(), String.t(), String.t()) ::
          {:ok, Req.Response.t()} | SwapifyApi.Errors.t()
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
          "Music-User-Token" => user_token,
          "Content-Type" => "application/json",
          "Content-Length" => 0
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
