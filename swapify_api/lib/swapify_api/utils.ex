defmodule SwapifyApi.Utils do
  @moduledoc "Group all utils function useful throughout the app"

  @doc """
  Convert every data that can be nil to either an `{:ok, data}` tuple or to a `{:ok, :not_found}`
  if the data is `nil`
  """
  @spec from_nullable_to_tuple(term() | nil) :: {:ok, term()} | {:error, :not_found}
  def from_nullable_to_tuple(nullable_data \\ nil) do
    if nullable_data == nil do
      {:error, :not_found}
    else
      {:ok, nullable_data}
    end
  end

  def prepare_request(req_options),
    do:
      req_options
      |> Keyword.merge(Application.fetch_env!(:swapify_api, :http_client_opts))
end
