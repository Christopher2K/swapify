defmodule SwapifyApi.Tasks.JobJSON do
  alias SwapifyApi.Tasks.Job

  @fields [
    :id,
    :name,
    :status,
    :updated_at,
    :user_id
  ]

  def show(%Job{} = j) do
    {to_serialize, _} = Map.split(j, @fields)
    to_serialize |> Recase.Enumerable.convert_keys(&Recase.to_camel/1)
  end

  def show(_), do: nil

  def list(job_list), do: job_list |> Enum.map(&show/1)
end
