defmodule SwapifyApi.Accounts.UserRepo do
  @moduledoc "User model repository"
  use OpenTelemetryDecorator

  import Ecto.Query

  alias SwapifyApi.Repo
  alias SwapifyApi.Accounts.User
  alias SwapifyApi.Utils

  @spec create(map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  @decorate with_span("user_repo.create")
  def create(data) do
    %User{}
    |> User.create_changeset(data)
    |> Repo.insert()
  end

  @spec get_by(atom(), String.t()) :: {:ok, User.t()} | {:error, ErrorMessage.t()}
  @decorate with_span("user_repo.get_by")
  def get_by(field, value) do
    User.queryable()
    |> User.filter_by(field, value)
    |> Repo.one()
    |> Utils.from_nullable_to_tuple()
  end

  @doc """
  Update a user
  """
  @spec update(User.t(), map()) :: {:ok, User.t()} | {:error, Ecto.Changeset.t()}
  @decorate with_span("user_repo.update")
  def update(user, attrs) do
    user
    |> User.update_changeset(attrs)
    |> Repo.update(returning: true)
  end

  @doc """
  List users
  """
  @spec list(pos_integer(), pos_integer()) :: {:ok, list(User.t())}
  @decorate with_span("user_repo.list")
  def list(offset \\ 0, limit \\ 20) do
    query =
      from user in User,
        offset: ^offset,
        limit: ^limit,
        order_by: [desc: user.inserted_at]

    {:ok, Repo.all(query)}
  end

  @doc """
  Count users
  """
  @spec count() :: {:ok, pos_integer()}
  @decorate with_span("user_repo.count")
  def count() do
    query =
      from user in User,
        select: count("*")

    Repo.one(query)
    |> Utils.from_nullable_to_tuple()
  end
end
