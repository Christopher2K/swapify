defmodule SwapifyApi.AppleMusicTest do
  use ExUnit.Case, async: true

  alias SwapifyApi.MusicProviders.AppleMusic
  alias Plug.Conn

  import SwapifyApi.AppleMusicAPIFixtures

  @fake_access_token "fake_at"
  @fake_developer_token "fake_dt"

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

  @tag mocked_response: user_library_response_fixture()
  test "get_user_library/4 returns a list of tracks" do
    assert {:ok, tracks, _} =
             AppleMusic.get_user_library(@fake_developer_token, @fake_access_token)

    assert length(tracks) == 1
  end
end
