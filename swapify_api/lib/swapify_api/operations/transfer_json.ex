defmodule SwapifyApi.Operations.TransferJSON do
  alias SwapifyApi.Operations.JobJSON
  alias SwapifyApi.MusicProviders.PlaylistJSON
  alias SwapifyApi.Operations.Transfer

  def show(%Transfer{} = t) do
    %{
      "id" => t.id,
      "destination" => t.destination,
      "sourcePlaylist" => PlaylistJSON.show(t.source_playlist),
      "matchingStepJob" => JobJSON.show(t.matching_step_job),
      "transferStepJob" => JobJSON.show(t.transfer_step_job),
      "insertedAt" => t.inserted_at,
      "updatedAt" => t.updated_at,
      "matchedTracks" => length(t.matched_tracks),
      "notFoundTracks" => length(t.not_found_tracks)
    }
  end

  def show(_), do: nil

  def list(transfer_list), do: transfer_list |> Enum.map(&show/1)
end
