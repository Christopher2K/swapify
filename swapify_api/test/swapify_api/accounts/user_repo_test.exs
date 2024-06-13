defmodule SwapifyApi.UserRepoTest do
  use SwapifyApi.DataCase

  alias SwapifyApi.Accounts.UserRepo
  alias SwapifyApi.Accounts.User

  import SwapifyApi.AccountsFixtures

  describe "create/1" do
    @tag :wip
    test "it creates a new user" do
      assert {:ok, user} =
               UserRepo.create(%{
                 "username" => "chris",
                 "email" => "chris@test.fr",
                 "password" => "password1234"
               })

      assert user.email == "chris@test.fr"
      assert user.username == "chris"
    end

    test "it fails when a user with the same email already exists" do
      email = "chris@test.fr"
      user_fixture(%{email: email})

      assert {:error, %Ecto.Changeset{}} =
               UserRepo.create(%{
                 "username" => "chris",
                 "email" => email,
                 "password" => "password1234"
               })
    end

    test "it fails when a user with the same username already exists" do
      username = "chris"
      user_fixture(%{username: username})

      assert {:error, %Ecto.Changeset{}} =
               UserRepo.create(%{
                 "username" => username,
                 "email" => "test@test.fr",
                 "password" => "password1234"
               })
    end

    test "it hashes the password" do
      password = "password"

      assert {:ok, user} =
               UserRepo.create(%{
                 "username" => "chris",
                 "email" => "chris@test.fr",
                 "password" => password
               })

      assert user.password != password
    end
  end

  describe "get_by/2" do
    test "it gets an user by its email" do
      email = "chris@test.fr"
      user_fixture(%{email: email})
      assert {:ok, %User{email: ^email}} = UserRepo.get_by(:email, email)
    end
  end
end
