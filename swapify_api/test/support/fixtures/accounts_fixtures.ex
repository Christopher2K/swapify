defmodule SwapifyApi.AccountsFixtures do
  @moduledoc "Fixture related to the account context"
  alias SwapifyApi.Repo
  alias SwapifyApi.Accounts.{User}

  def user_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        email: Faker.Internet.email(),
        password: Faker.UUID.v4()
      })

    {:ok, user} =
      %User{}
      |> User.changeset(attrs)
      |> Repo.insert()

    user
  end
end
