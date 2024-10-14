defmodule SwapifyApi.Tasks do
  @moduledoc """
  Task contexts
  """
  alias SwapifyApi.Tasks.JobRepo
  alias SwapifyApi.Tasks.Job

  @doc """
  Handle Oban insertion error when a domain job is involved
  """
  @spec handle_oban_insertion_error(any(), Job.t()) :: {:ok, Job.t()} | SwapifyApi.Errors.t()
  def handle_oban_insertion_error(result, %Job{} = job) do
    case result do
      {:ok, %{id: nil, conflict?: true}} ->
        JobRepo.update(job.id, %{
          "status" => :error
        })

        SwapifyApi.Errors.failed_to_acquire_lock()

      {:ok, %{conflict?: true}} ->
        JobRepo.update(job.id, %{
          "status" => :error
        })

        SwapifyApi.Errors.job_already_exists()

      {:ok, _} ->
        {:ok, job}

      {:error, _} ->
        JobRepo.update(job.id, %{
          "status" => :error
        })

        SwapifyApi.Errors.oban_error()
    end
  end
end
