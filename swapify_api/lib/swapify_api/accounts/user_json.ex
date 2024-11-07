defmodule SwapifyApi.Accounts.UserJSON do
  alias SwapifyApi.Accounts.User

  @fields [
    :id,
    :username,
    :email,
    :role,
    :inserted_at,
    :updated_at
  ]

  def show(%User{} = u) do
    {to_serialize, _} = Map.split(u, @fields)
    to_serialize |> Recase.Enumerable.convert_keys(&Recase.to_camel/1)
  end

  def list(user_list), do: user_list |> Enum.map(&show/1)
end
