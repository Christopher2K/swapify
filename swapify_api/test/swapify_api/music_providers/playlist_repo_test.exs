defmodule SwapifyApi.PlaylistRepoTest do
  alias SwapifyApi.MusicProviders.Track
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
        "user_id" => user.id,
        "tracks" => base_tracks,
        "platform_name" => :spotify,
        "platform_id" => "custom_id"
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
          "user_id" => user.id,
          "tracks" => base_tracks,
          "platform_name" => :spotify,
          "platform_id" => "custom_id"
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
          "user_id" => user.id,
          "tracks" => base_tracks,
          "platform_name" => :spotify,
          "platform_id" => "custom_id"
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
          "user_id" => user.id,
          "sync_status" => :synced
        })

      assert {:ok, %Playlist{} = p} = PlaylistRepo.update_status(playlist.id, :error)
      assert p.sync_status == :error
    end
  end

  describe "get_playlist_track_by_index/2" do
    setup do
      user = user_fixture()
      tracks = for _ <- 1..10, do: track_fixture()

      playlist =
        playlist_fixture(%{
          "user_id" => user.id,
          "tracks" => tracks,
          "platform_name" => :spotify,
          "platform_id" => "custom_id"
        })

      {:ok, playlist: playlist, tracks: tracks}
    end

    test "it should return the correct track by its index", %{playlist: playlist} do
      assert {:ok, %Track{}} = PlaylistRepo.get_playlist_track_by_index(playlist.id, 0)
    end

    test "it should return the not found tuple if the track was not found", %{
      playlist: playlist
    } do
      assert {:error, %ErrorMessage{code: :not_found}} =
               PlaylistRepo.get_playlist_track_by_index(playlist.id, 1000)
    end
  end

  describe "get_playlist_tracks/3" do
    setup do
      user = user_fixture()
      tracks = for _ <- 1..10, do: track_fixture()

      playlist =
        playlist_fixture(%{
          "user_id" => user.id,
          "tracks" => tracks,
          "platform_name" => :spotify,
          "platform_id" => "custom_id"
        })

      {:ok, playlist: playlist, tracks: tracks}
    end

    test "it should return the 3 first tracks", %{playlist: playlist} do
      assert {:ok, result} = PlaylistRepo.get_playlist_tracks(playlist.id, 0, 3)
      assert length(result) == 3
    end

    test "it should return an empty array when offset/limit combo of out of bounds", %{
      playlist: playlist
    } do
      assert {:ok, result} = PlaylistRepo.get_playlist_tracks(playlist.id, 1000, 1000)
      assert length(result) == 0
    end
  end
end
