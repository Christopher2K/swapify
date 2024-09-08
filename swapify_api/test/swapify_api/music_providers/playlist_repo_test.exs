defmodule SwapifyApi.PlaylistRepoTest do
  alias SwapifyApi.MusicProviders.Playlist
  use SwapifyApi.DataCase

  alias SwapifyApi.MusicProviders.PlaylistRepo

  import SwapifyApi.MusicProvidersFixtures
  import SwapifyApi.AccountsFixtures

  describe "create_or_update/3" do
    setup do
      user = user_fixture()
      {:ok, user: user}
    end

    test "it creates a playlist that does not exist for the given user and platform", %{
      user: user
    } do
      assert {:ok, %Playlist{}} =
               PlaylistRepo.create_or_update(
                 :spotify,
                 user.id,
                 user.id,
                 0
               )
    end

    test "it updates an existing playlist", %{
      user: user
    } do
      base_tracks = for _ <- 1..3, do: track_fixture()

      playlist_fixture(%{
        user_id: user.id,
        tracks: base_tracks,
        platform_name: :spotify,
        platform_id: "custom_id"
      })

      assert {:ok, %Playlist{tracks_total: 1000, name: "updated playlist", sync_status: :synced}} =
               PlaylistRepo.create_or_update(
                 :spotify,
                 "custom_id",
                 user.id,
                 1000,
                 :synced,
                 "updated playlist"
               )
    end
  end

  describe "add_tracks/5" do
    setup do
      user = user_fixture()
      {:ok, user: user}
    end

    test "it should replace tracks on a playlist", %{
      user: user
    } do
      base_tracks = for _ <- 1..3, do: track_fixture()
      new_tracks = for _ <- 1..5, do: track_fixture(%{}, as_struct: true)

      playlist =
        playlist_fixture(%{
          user_id: user.id,
          tracks: base_tracks,
          platform_name: :spotify,
          platform_id: "custom_id"
        })

      assert {:ok, %Playlist{} = p} =
               PlaylistRepo.add_tracks(
                 playlist.id,
                 new_tracks,
                 10,
                 :syncing,
                 replace_tracks: true
               )

      assert Enum.count(p.tracks) == 5
    end

    test "it should add tracks to a playlist", %{
      user: user
    } do
      base_tracks = for _ <- 1..10, do: track_fixture()
      new_tracks = for _ <- 1..5, do: track_fixture(%{}, as_struct: true)

      playlist =
        playlist_fixture(%{
          user_id: user.id,
          tracks: base_tracks,
          platform_name: :spotify,
          platform_id: "custom_id"
        })

      assert {:ok, %Playlist{} = p} =
               PlaylistRepo.add_tracks(
                 playlist.id,
                 new_tracks,
                 10,
                 :syncing
               )

      assert Enum.count(p.tracks) == 15
    end
  end

  describe "update_status/2" do
    setup do
      user = user_fixture()
      {:ok, user: user}
    end

    test "it should update the playlist status", %{
      user: user
    } do
      playlist =
        playlist_fixture(%{
          user_id: user.id,
          sync_status: :synced
        })

      assert {:ok, %Playlist{} = p} = PlaylistRepo.update_status(playlist.id, :error)
      assert p.sync_status == :error
    end
  end
end
