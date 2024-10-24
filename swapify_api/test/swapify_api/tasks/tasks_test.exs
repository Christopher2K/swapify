defmodule SwapifyApi.TasksTest do
  use SwapifyApi.DataCase

  alias SwapifyApi.Tasks
  alias SwapifyApi.Tasks.Job
  alias SwapifyApi.Tasks.Transfer

  import SwapifyApi.TasksFixtures
  import SwapifyApi.AccountsFixtures
  import SwapifyApi.MusicProvidersFixtures

  describe "update_job_status/2" do
    setup do
      user = user_fixture()

      job =
        job_fixture(%{
          "user_id" => user.id,
          "status" => :started
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
      playlist = playlist_fixture(%{"user_id" => user.id})
      {:ok, user: user, playlist: playlist}
    end

    test "it cancels a cancelable transfer", %{user: user, playlist: playlist} do
      matching_job = job_fixture(%{"user_id" => user.id, "status" => :done})

      transfer =
        transfer_fixture(%{
          "matching_step_job_id" => matching_job.id,
          "source_playlist_id" => playlist.id,
          "user_id" => user.id
        })

      assert {:ok, %Transfer{} = transfer} = Tasks.cancel_transfer(user.id, transfer.id)
      assert transfer.matching_step_job.status == :canceled
    end

    test "it returns an error if the transfer is not cancelable", %{
      user: user,
      playlist: playlist
    } do
      matching_job = job_fixture(%{"user_id" => user.id, "status" => :started})

      transfer =
        transfer_fixture(%{
          "matching_step_job_id" => matching_job.id,
          "source_playlist_id" => playlist.id,
          "user_id" => user.id
        })

      assert {:error, :transfer_cancel_error} = Tasks.cancel_transfer(user.id, transfer.id)
    end
  end
end
