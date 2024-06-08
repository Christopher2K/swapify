defmodule SwapifyApi.UserRepoTest do
  use SwapifyApi.DataCase

  alias SwapifyApi.Accounts.UserRepo

  import SwapifyApi.AccountsFixtures

  describe "create/1" do
    test "it creates a new user" do
      assert {:ok, user} =
               UserRepo.create(%{
                 "email" => "chris@test.fr",
                 "password" => "password1234"
               })

      assert user.email == "chris@test.fr"
    end

    test "it fails when a user with the same email already exists" do
      email = "chris@test.fr"
      user_fixture(%{email: email})

      assert {:error, %Ecto.Changeset{}} =
               UserRepo.create(%{
                 "email" => email,
                 "password" => "password1234"
               })
    end

    test "it hashes the password" do
      password = "password"

      assert {:ok, user} =
               UserRepo.create(%{
                 "email" => "chris@test.fr",
                 "password" => password
               })

      assert user.password != password
    end
  end
end
