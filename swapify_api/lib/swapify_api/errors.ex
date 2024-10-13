defmodule SwapifyApi.Errors do
  @moduledoc """
  Dictionary of all app wide errors
  """

  @type t :: {:error, atom()}

  ## GENERIC ERRORS
  def not_found(), do: {:error, :not_found}
  def not_found_message(), do: "Could not find the requested resource."

  ## HTTP SERVICE ERRORS
  @spec http_service_error(pos_integer()) :: t()
  def http_service_error(code), do: {:error, code |> Integer.to_string() |> String.to_atom()}

  def http_service_error_message(),
    do: "An error occurred while trying to reach an external service. Please try again."

  ## OAUTH SPECIFIC ERRORS
  def state_mismatch(), do: {:error, :state_mismatch}
  def state_mismatch_message(), do: "Error while trying to authenticate. Please try again."
end
