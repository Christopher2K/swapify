defmodule SwapifyApi.Tasks.Services.StartPlaylistTransferTransferStep do
  @moduledoc """
  Start the playlist transfer second step: summary job
  This step is about:
  - Getting the transfer and make sure domain invariant are valid
  - Getting the playlist and the results of the find job
  - Compare what has been found or not found and generate a report
  """
  alias SwapifyApi.Tasks.TransferRepo

  def call(user_id, transfer_id) do
    with {:ok, transfer} = TransferRepo.get_transfer_by_step_and_id(transfer_id, :matching) do

    end
  end
end
