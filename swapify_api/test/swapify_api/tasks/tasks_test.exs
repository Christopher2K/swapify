defmodule SwapifyApi.TasksTest do
  use SwapifyApi.DataCase

  alias SwapifyApi.Tasks
  alias SwapifyApi.Tasks.Job

  import SwapifyApi.TasksFixtures
  import SwapifyApi.AccountsFixtures

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
end
