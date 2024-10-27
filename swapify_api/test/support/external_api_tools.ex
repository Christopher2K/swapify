defmodule SwapifyApi.ExternalAPITools do
  @moduledoc """
  Tools to test external APIs
  """

  alias Plug.Conn

  @doc """
  Call this function in your setup test function.
  Every test can now pass a `mocked_responses` array to handle external API calls made by code
  A mocked response item expects:
  - host - The host of the API
  - path - The path of the API
  - body - The body of the response
  - status - The status code of the response
  """
  def handle_mocked_response(ctx) do
    mocked_responses = Map.get(ctx, :mocked_responses, [])

    Req.Test.stub(:test, fn conn ->
      mb_response =
        mocked_responses
        |> Enum.find(fn mocked_response ->
          mocked_response.host == conn.host &&
            mocked_response.path == conn.request_path
        end)

      case mb_response do
        nil ->
          Req.Test.json(
            Conn.put_status(conn, 200),
            %{}
          )

        response ->
          Req.Test.json(
            conn |> Conn.put_status(Map.get(response, :status, 200)),
            Map.get(response, :body, %{})
          )
      end
    end)
  end
end
