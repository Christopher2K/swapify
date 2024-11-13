defmodule SwapifyApi.MusicProvidersTest do
  use SwapifyApi.DataCase

  import SwapifyApi.AccountsFixtures
  import SwapifyApi.MusicProvidersFixtures

  alias SwapifyApi.MusicProviders
  alias SwapifyApi.Tasks.Job

  describe "start_library_sync/2" do
    setup do
      user = user_fixture()
      spotify_pc = platform_connection_fixture(%{user_id: user.id, name: :spotify})
      am_pc = platform_connection_fixture(%{user_id: user.id, name: :applemusic})

      spotify_library =
        playlist_fixture(%{
          "user_id" => user.id,
          "platform_name" => :spotify,
          "platform_id" => user.id
        })

      am_library =
        playlist_fixture(%{
          "user_id" => user.id,
          "platform_name" => :applemusic,
          "platform_id" => user.id
        })

      {:ok,
       user: user,
       spotify_pc: spotify_pc,
       am_pc: am_pc,
       spotify_library: spotify_library,
       am_library: am_library}
    end

    test "it should start a platforn sync job for a given user", %{
      user: user,
      spotify_pc: spotify_pc
    } do
      assert {:ok, %Job{} = job} = MusicProviders.start_library_sync(user.id, :spotify)

      assert_enqueued(
        worker: MusicProviders.Jobs.SyncLibraryJob,
        args: %{
          "access_token" => spotify_pc.access_token,
          "job_id" => job.id,
          "offset" => 0,
          "platform_name" => "spotify",
          "refresh_token" => spotify_pc.refresh_token,
          "user_id" => user.id
        }
      )
    end

    test "it should not start a platform sync twice", %{user: user} do
      assert {:ok, %Job{}} = MusicProviders.start_library_sync(user.id, :spotify)

      assert {:error, %ErrorMessage{code: :conflict}} =
               MusicProviders.start_library_sync(user.id, :spotify)
    end
  end

  describe "start_platform_sync/2" do
    setup do
      user = user_fixture()
      spotify_pc = platform_connection_fixture(%{user_id: user.id, name: :spotify})
      am_pc = platform_connection_fixture(%{user_id: user.id, name: :applemusic})

      {:ok, user: user, spotify_pc: spotify_pc, am_pc: am_pc}
    end

    test "it should start a platforn sync job for a given user", %{
      user: user,
      spotify_pc: spotify_pc
    } do
      assert {:ok, %Job{} = job} = MusicProviders.start_platform_sync(user.id, :spotify)

      assert_enqueued(
        worker: MusicProviders.Jobs.SyncPlatformJob,
        args: %{
          "access_token" => spotify_pc.access_token,
          "job_id" => job.id,
          "platform_name" => "spotify",
          "refresh_token" => spotify_pc.refresh_token,
          "should_sync_library" => true,
          "user_id" => user.id
        }
      )
    end

    test "it should not start a platform sync twice", %{user: user} do
      assert {:ok, %Job{}} = MusicProviders.start_platform_sync(user.id, :spotify)

      assert {:error, %ErrorMessage{code: :conflict}} =
               MusicProviders.start_platform_sync(user.id, :spotify)
    end
  end
end
