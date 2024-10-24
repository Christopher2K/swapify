defmodule SwapifyApi.Errors do
  @moduledoc """
  Dictionary of all app wide errors
  """

  @type t :: {:error, atom()}

  ## GENERIC ERRORS
  def not_found(), do: {:error, :not_found}
  def not_found_details(), do: {404, "Could not find the requested resource."}

  def server_error(), do: {:error, :server_error}
  def server_error_details(), do: {500, "An error occurred. Please try again."}

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

  ## SPECIFIC ERRORS
  def state_mismatch(), do: {:error, :state_mismatch}
  def state_mismatch_details(), do: {401, "Error while trying to authenticate. Please try again."}

  def auth_failed(), do: {:error, :auth_failed}
  def auth_failed_details(), do: {401, "Invalid email or password."}

  def token_invalid(), do: {:error, :token_invalid}
  def token_invalid_details(), do: {401, "Invalid token."}

  def job_already_exists(), do: {:error, :job_already_exists}
  def job_already_exists_details(), do: {409, "A similar operation is already in progress."}

  def failed_to_acquire_lock(), do: {:error, :failed_to_acquire_lock}
  def failed_to_acquire_lock_details(), do: {409, "A similar operation is already in progress."}

  def oban_error(), do: {:error, :oban_error}
  def oban_error_details(), do: {500, "An error occurred. Please try again."}

  def transfer_cancel_error(), do: {:error, :transfer_cancel_error}

  def transfer_cancel_error_details(),
    do: {400, "The transfer cannot be cancelled in its current state."}

  ## GET MESSAGE
  def get_details(error_atom) do
    case error_atom do
      :not_found ->
        not_found_details()

      :state_mismatch ->
        state_mismatch_details()

      :server_error ->
        server_error_details()

      :auth_failed ->
        auth_failed_details()

      :token_invalid ->
        token_invalid_details()

      :job_already_exists ->
        job_already_exists_details()

      :failed_to_acquire_lock ->
        failed_to_acquire_lock_details()

      :oban_error ->
        oban_error_details()

      :transfer_cancel_error ->
        transfer_cancel_error_details()

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
