defmodule SwapifyApi.Utils do
  @moduledoc "Group all utils function useful throughout the app"

  @doc """
  Convert every data that can be nil to either an `{:ok, data}` tuple or to a `ErrorMessage.t()`
  if the data is `nil`
  """
  @spec from_nullable_to_tuple(term() | nil) :: {:ok, term()} | {:error, ErrorMessage.t()}
  def from_nullable_to_tuple(nullable_data \\ nil) do
    if nullable_data == nil do
      {:error, ErrorMessage.not_found("Could not find the requested resource.")}
    else
      {:ok, nullable_data}
    end
  end

  def prepare_request(req_options),
    do:
      req_options
      |> Keyword.merge(Application.fetch_env!(:swapify_api, :http_client_opts))

  def struct_to_json(s),
    do: Map.from_struct(s) |> Recase.Enumerable.convert_keys(&Recase.to_camel/1)

  @spec get_module_name(atom()) :: String.t()
  def get_module_name(module_name) do
    module_name
    |> Atom.to_string()
    |> String.split(".")
    |> case do
      ["Elixir" | rest] -> rest
      fragments -> fragments
    end
    |> Enum.join(".")
  end

  def get_app_url("/" <> _path = path),
    do: Application.fetch_env!(:swapify_api, :app_url) <> "/app" <> path

  def get_app_url(),
    do: Application.fetch_env!(:swapify_api, :app_url) <> "/app"

  @doc """
  Handle Oban insertion errors
  """
  @spec check_oban_insertion_result(any()) :: {:ok, Oban.Job.t()} | {:error, ErrorMessage.t()}
  def check_oban_insertion_result(result) do
    case result do
      {:ok, %{id: nil, conflict?: true}} ->
        {:error, ErrorMessage.bad_request("Failed to start the operation. Please try again.")}

      {:ok, %{conflict?: true}} ->
        {:error, ErrorMessage.conflict("A similar operation is already in progress.")}

      {:ok, oban_job} ->
        {:ok, oban_job}

      {:error, error} ->
        {:error,
         ErrorMessage.internal_server_error("A similar operation is already in progress.", %{
           details: error
         })}
    end
  end

  @doc """
  Flatten results after a Ecto.Multi transaction
  """
  @spec handle_transaction_result({:ok, map()} | {:error, any(), any(), any()}) ::
          {:ok, any()} | {:error, ErrorMessage.t()}
  def handle_transaction_result({:ok, %{result: result}}), do: {:ok, result}
  def handle_transaction_result({:error, _, reason, _}), do: {:error, reason}
  def handle_transaction_result(error), do: error
end
