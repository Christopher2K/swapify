defmodule SwapifyApi.SpotifyTest do
  use ExUnit.Case, async: true

  alias SwapifyApi.MusicProviders.Spotify
  alias SwapifyApi.Oauth
  alias Plug.Conn

  import SwapifyApi.SpotifyAPIFixtures

  @fake_access_token "fake_at"
  @fake_refresh_token "fake_rt"

  setup ctx do
    mocked_response = Map.get(ctx, :mocked_response, %{})
    mocked_status = Map.get(ctx, :mocked_status, 200)

    Req.Test.stub(:test, fn conn ->
      Req.Test.json(
        conn |> Conn.put_status(mocked_status),
        mocked_response
      )
    end)

    :ok
  end

  @tag mocked_response: request_access_token_response_fixture()
  test "request_access_token/1 returns an access_token on success" do
    assert {:ok,
            %Oauth.AccessToken{
              access_token: @fake_access_token,
              refresh_token: @fake_refresh_token
            }} = Spotify.request_access_token("fake_code")
  end

  @tag mocked_status: 400
  test "request_access_token/1 returns an error on http error" do
    assert {:error, %{details: %{status: 400}}} = Spotify.request_access_token("fake_code")
  end

  @tag mocked_response: %{
         "access_token" => @fake_access_token,
         "refresh_token" => @fake_refresh_token,
         "expires_in" => 3600
       }
  test "refresh_access_token/1 returns an access_token on success" do
    assert {:ok,
            %Oauth.AccessToken{
              access_token: @fake_access_token,
              refresh_token: @fake_refresh_token
            }} = Spotify.refresh_access_token(@fake_refresh_token)
  end

  @tag mocked_response: user_library_response_fixture()
  test "get_user_library/1 returns a list of tracks" do
    assert {:ok, tracks, _} = Spotify.get_user_library(@fake_access_token)
    assert length(tracks) == 1
  end
end
