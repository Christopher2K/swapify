defmodule SwapifyApi.TasksTest do
  alias SwapifyApi.MusicProviders
  use SwapifyApi.DataCase

  alias SwapifyApi.Tasks
  alias SwapifyApi.Tasks.Job
  alias SwapifyApi.Tasks.Transfer

  import SwapifyApi.TasksFixtures
  import SwapifyApi.AccountsFixtures
  import SwapifyApi.MusicProvidersFixtures
  import SwapifyApi.ScenarioFixtures

  describe "update_job_status/2" do
    setup do
      user = user_fixture()

      job =
        job_fixture(%{
          user_id: user.id,
          status: :started
        })

      {:ok, job: job}
    end

    test "it sets the done_at value to the current date time when the status is :done", %{
      job: job
    } do
      assert {:ok, %Job{} = job} = Tasks.update_job_status(job.id, :done)
      assert job.done_at != nil
    end

    test "it sets the canceled_at value to the current date time when the status is :canceled", %{
      job: job
    } do
      assert {:ok, %Job{done_at: nil} = job} = Tasks.update_job_status(job.id, :canceled)
      assert job.canceled_at != nil
    end

    test "it sets the canceled_at value to the current date time when the status is :error", %{
      job: job
    } do
      assert {:ok, %Job{done_at: nil} = job} = Tasks.update_job_status(job.id, :error)
      assert job.canceled_at != nil
    end
  end

  describe "cancel_transfer/2" do
    setup do
      user = user_fixture()
      playlist = playlist_fixture(%{user_id: user.id})
      {:ok, user: user, playlist: playlist}
    end

    test "it cancels a cancelable transfer", %{user: user, playlist: playlist} do
      matching_job = job_fixture(%{user_id: user.id, status: :done})

      transfer =
        transfer_fixture(%{
          matching_step_job_id: matching_job.id,
          source_playlist_id: playlist.id,
          user_id: user.id
        })

      assert {:ok, %Transfer{} = transfer} = Tasks.cancel_transfer(user.id, transfer.id)
      assert transfer.matching_step_job.status == :canceled
    end

    test "it returns an error if the transfer is not cancelable", %{
      user: user,
      playlist: playlist
    } do
      matching_job = job_fixture(%{user_id: user.id, status: :started})

      transfer =
        transfer_fixture(%{
          matching_step_job_id: matching_job.id,
          source_playlist_id: playlist.id,
          user_id: user.id
        })

      assert {:error, %ErrorMessage{code: :bad_request}} =
               Tasks.cancel_transfer(user.id, transfer.id)
    end
  end

  describe "start_playlist_transfer_matching_step/2" do
    setup do
      new_user_with_all_music_providers_enabled_with_libraries()
    end

    test "it should start a playlist transfer", %{
      user: user,
      spotify_library: spotify_library,
      spotify_pc: spotify_pc
    } do
      assert {:ok, %{transfer: transfer, job: job}} =
               Tasks.start_playlist_transfer_matching_step(user.id, spotify_library.id, :spotify)

      assert_enqueued(
        worker: MusicProviders.Jobs.FindPlaylistTracksJob,
        args: %{
          "access_token" => spotify_pc.access_token,
          "job_id" => job.id,
          "offset" => 0,
          "playlist_id" => spotify_library.id,
          "refresh_token" => spotify_pc.refresh_token,
          "target_platform" => "spotify",
          "transfer_id" => transfer.id,
          "unsaved_not_found_tracks" => [],
          "unsaved_tracks" => [],
          "user_id" => user.id
        }
      )
    end

    test "it should not start a playlist transfer twice", %{
      user: user,
      spotify_library: spotify_library
    } do
      assert {:ok, %{transfer: _, job: _}} =
               Tasks.start_playlist_transfer_matching_step(user.id, spotify_library.id, :spotify)

      assert {:error, %ErrorMessage{code: :conflict}} =
               Tasks.start_playlist_transfer_matching_step(user.id, spotify_library.id, :spotify)
    end
  end

  describe "start_playlist_transfer_transfer_step/2" do
    setup do
      {:ok, kw} = new_user_with_all_music_providers_enabled_with_libraries()
      user = Keyword.get(kw, :user)
      spotify_library = Keyword.get(kw, :spotify_library)

      job =
        job_fixture(%{
          status: :done,
          done_at: DateTime.utc_now(),
          user_id: user.id
        })

      transfer =
        transfer_fixture(%{
          user_id: user.id,
          destination: :applemusic,
          matching_step_job_id: job.id,
          source_playlist_id: spotify_library.id
        })

      {:ok, kw |> Keyword.put(:transfer, transfer)}
    end

    test "it should start the second step of a playlist transfer", %{
      user: user,
      transfer: transfer,
      am_pc: am_pc
    } do
      assert {:ok, %{transfer: transfer, job: job}} =
               Tasks.start_playlist_transfer_transfer_step(user.id, transfer.id)

      assert_enqueued(
        worker: MusicProviders.Jobs.TransferTracksJob,
        args: %{
          "access_token" => am_pc.access_token,
          "is_library" => true,
          "job_id" => job.id,
          "offset" => 0,
          "refresh_token" => am_pc.refresh_token,
          "target_platform" => "applemusic",
          "transfer_id" => transfer.id,
          "user_id" => user.id
        }
      )
    end

    test "it should fail to start the second step if it's already running", %{
      user: user,
      transfer: transfer
    } do
      assert {:ok, %{transfer: %Transfer{}}} =
               Tasks.start_playlist_transfer_transfer_step(user.id, transfer.id)

      assert {:error, %ErrorMessage{}} =
               Tasks.start_playlist_transfer_transfer_step(user.id, transfer.id)
    end
  end
end
