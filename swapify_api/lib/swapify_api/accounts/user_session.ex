defmodule SwapifyApi.Accounts.UserSession do
  alias SwapifyApi.Accounts.User

  @session_key :user

  @doc """
  Keep the user id in the session
  """
  @spec create_user_session(Plug.Conn.t(), User.t()) :: Plug.Conn.t()
  def create_user_session(%Plug.Conn{} = conn, %User{} = user) do
    Plug.Conn.put_session(conn, @session_key, %{id: user.id})
  end

  @doc """
  On success, returns a map containing an `id` property, representing an user
  """
  @spec get_user_session(Plug.Conn.t()) :: {:error, :forbidden} | {:ok, map()}
  def get_user_session(%Plug.Conn{} = conn) do
    case Plug.Conn.get_session(conn, @session_key, nil) do
      nil -> {:error, :forbidden}
      user_data -> {:ok, user_data}
    end
  end

  @doc """
  Removes all user info in the session
  """
  @spec delete_user_session(Plug.Conn.t()) :: any()
  def delete_user_session(%Plug.Conn{} = conn) do
    Plug.Conn.delete_session(conn, @session_key)
  end
end
