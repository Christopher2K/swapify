defmodule SwapifyApi.AccountsFixtures do
  @moduledoc "Fixture related to the account context"
  import SwapifyApi.ValuesFixtures

  alias SwapifyApi.Repo
  alias SwapifyApi.Accounts.User
  alias SwapifyApi.Accounts.PlatformConnection

  def user_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        username: Faker.Internet.user_name() |> String.slice(0..20),
        email: Faker.Internet.email(),
        password: Faker.UUID.v4()
      })

    {:ok, user} =
      %User{}
      |> User.changeset(attrs)
      |> Repo.insert()

    user
  end

  def platform_connection_fixture(attrs \\ %{}) do
    platform_name = random_platform_name()
    refresh_token = if platform_name == :spotify, do: Faker.UUID.v4(), else: nil

    attrs =
      attrs
      |> Enum.into(%{
        name: platform_name,
        country_code: Faker.Address.country_code(),
        access_token: Faker.UUID.v4(),
        access_token_exp: DateTime.utc_now() |> DateTime.add(3600, :second),
        refresh_token: refresh_token
      })

    {:ok, platform_connection} =
      %PlatformConnection{}
      |> PlatformConnection.changeset(attrs)
      |> Repo.insert()

    platform_connection
  end
end
