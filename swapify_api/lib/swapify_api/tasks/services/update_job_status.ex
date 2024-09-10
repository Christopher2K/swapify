defmodule SwapifyApi.Tasks.Services.UpdateJobStatus do
  alias SwapifyApi.Tasks.JobRepo
  alias SwapifyApi.Tasks.Job

  @spec call(String.t(), Job.job_status()) :: any()
  def call(job_id, new_status),
    do:
      JobRepo.update(job_id, %{
        "status" => new_status
      })
end
