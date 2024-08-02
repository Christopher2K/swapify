defmodule SwapifyApiWeb.PlaylistController do
  use SwapifyApiWeb, :controller

  alias SwapifyApi.MusicProviders.PlaylistRepo

  @doc """
  Get user libraries for all or a given platform
  """
  def get_library(conn, params) do
    user_id = conn.assigns[:user_id]
    platform = params["platform"]

    data =
      case platform do
        nil ->
          PlaylistRepo.get_user_libraries(user_id)

        _ ->
          PlaylistRepo.get_library_by_user_id_and_platform(
            user_id,
            platform
          )
      end

    case data do
      {:ok, playlists} when is_list(playlists) ->
        conn
        |> put_status(200)
        |> render(:index, playlists: playlists)

      {:ok, playlist} ->
        conn
        |> put_status(200)
        |> render(:index, playlists: [playlist])

      error ->
        error
    end
  end
end
