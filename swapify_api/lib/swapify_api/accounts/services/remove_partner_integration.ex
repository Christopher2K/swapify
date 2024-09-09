defmodule SwapifyApi.Accounts.Services.RemovePartnerIntegration do
  @moduledoc "Refresh the access token of a partner integration"
  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Accounts.PlatformConnectionRepo

  @spec call(String.t(), PlatformConnection.platform_name()) ::
          {:ok, PlatformConnection.t()} | {:error, atom()}
  def call(user_id, platform_name) do
    PlatformConnectionRepo.delete(user_id, platform_name)
  end
end
