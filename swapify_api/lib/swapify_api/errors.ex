defmodule SwapifyApi.Errors do
  @moduledoc """
  Dictionary of all app wide errors
  """

  @type t :: {:error, atom()}

  ## GENERIC ERRORS
  def not_found(), do: {:error, :not_found}
  def not_found_details(), do: {404, "Could not find the requested resource."}

  ## HTTP SERVICE ERRORS
  @spec http_service_error(pos_integer()) :: t()
  def http_service_error(code),
    do:
      {:error,
       code
       |> Integer.to_string()
       |> then(fn error_as_string -> "service_" <> error_as_string end)
       |> String.to_atom()}

  def http_service_error_details(),
    do: {500, "An error occurred while trying to reach an external service. Please try again."}

  ## OAUTH SPECIFIC ERRORS
  def state_mismatch(), do: {:error, :state_mismatch}
  def state_mismatch_details(), do: {401, "Error while trying to authenticate. Please try again."}

  ## GET MESSAGE
  def get_details(error_atom) do
    case error_atom do
      :not_found ->
        not_found_details()

      :state_mismatch ->
        state_mismatch_details()

      err when is_atom(err) ->
        if err |> Atom.to_string() |> String.starts_with?("service_") do
          http_service_error_details()
        else
          {500, "A server error occurred. Please try again. " <> Atom.to_string(err)}
        end

      _ ->
        {500, "A server error occurred. Please try again."}
    end
  end
end
