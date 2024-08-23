defmodule SwapifyApi.PlaylistRepoTest do
  alias SwapifyApi.MusicProviders.Playlist
  use SwapifyApi.DataCase

  alias SwapifyApi.MusicProviders.PlaylistRepo

  import SwapifyApi.MusicProvidersFixtures
  import SwapifyApi.AccountsFixtures

  describe "update/2" do
    setup do
      user = user_fixture()
      tracks = for _ <- 1..5, do: track_fixture()
      playlist = playlist_fixture(%{user_id: user.id, tracks: tracks})

      {:ok, user: user, playlist: playlist}
    end

    test "it adds tracks to a playlist and updates its status", %{
      playlist: playlist
    } do
      tracks = for _ <- 1..10, do: track_fixture(%{}, as_struct: true)

      assert {:ok, %Playlist{} = p} =
               PlaylistRepo.update(playlist.id, %{
                 "+tracks" => tracks,
                 "sync_status" => :synced,
                 "tracks_total" => 15
               })

      assert length(p.tracks) == 15
      assert p.tracks_total == 15
      assert p.sync_status == :synced
    end
  end
end
