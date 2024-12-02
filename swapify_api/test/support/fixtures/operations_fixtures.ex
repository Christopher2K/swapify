defmodule SwapifyApi.OperationsFixtures do
  alias SwapifyApi.Repo
  alias SwapifyApi.Operations.MatchedTrack
  alias SwapifyApi.Operations.Transfer
  alias SwapifyApi.Operations.Job

  import SwapifyApi.ValuesFixtures

  def transfer_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        destination: random_platform_name()
      })

    {:ok, transfer} =
      %Transfer{}
      |> Transfer.changeset(attrs)
      |> Repo.insert()

    transfer
  end

  def matched_track_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        "isrc" => Faker.UUID.v4(),
        "platform_id" => Faker.UUID.v4(),
        "platform_link" => Faker.Internet.url()
      })

    {:ok, transfer} =
      %MatchedTrack{}
      |> MatchedTrack.changeset(attrs)
      |> Ecto.Changeset.apply_action(:insert)

    transfer
  end

  def job_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        name: Faker.Lorem.word(),
        status: random_job_status(),
        oban_job_args: %{}
      })

    {:ok, job} =
      %Job{}
      |> Job.changeset(attrs)
      |> Repo.insert()

    job
  end
end
