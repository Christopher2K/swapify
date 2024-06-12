defmodule SwapifyApi.MusicProviders.Spotify do
  @moduledoc "Interface to talk with Spotify"
  require Logger

  alias SwapifyApi.Utils
  alias SwapifyApi.Oauth

  @account_url "https://accounts.spotify.com"
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
          {:ok, Oauth.AccessToken.t()} | {:error, non_neg_integer() | atom()}
  def request_access_token(authorization_code) do
    body = %{
      "grant_type" => "code",
      "redirect_uri" => @redirect_uri,
      "code" => authorization_code
    }

    client_id = get_client_id() |> Base.encode64()
    client_secret = get_client_secret() |> Base.encode64()
    token = "#{client_id}:#{client_secret}"

    uri = @account_url <> "/api/token"

    result =
      [
        method: :post,
        url: uri,
        auth: {:bearer, token},
        form: body
      ]
      |> Utils.prepare_request()
      |> Req.request()

    case result do
      {:ok, %Req.Response{status: 200} = response} ->
        result = response.body |> Oauth.AccessToken.from_map()
        {:ok, result}

      {:ok, %Req.Response{status: status}} ->
        {:error, status}

      {:error, exception} ->
        Logger.error(exception)
        {:error, :service_error}
    end
  end
end
