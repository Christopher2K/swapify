defmodule SwapifyApi.UserRepoTest do
  use SwapifyApi.DataCase

  alias SwapifyApi.Accounts.UserRepo
  alias SwapifyApi.Accounts.User

  import SwapifyApi.AccountsFixtures

  describe "create/1" do
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
      password = "password1234"

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

    test "it get an user by its id" do
      %{id: user_id} = user_fixture()
      assert {:ok, %User{id: ^user_id}} = UserRepo.get_by(:id, user_id)
    end
  end

  describe "list/2" do
    test "it returns 20 users max by default" do
      for _ <- 0..40, do: user_fixture()
      {:ok, result} = UserRepo.list()
      assert length(result) == 20
    end

    test "it limits the possible results" do
      for _ <- 0..40, do: user_fixture()
      {:ok, result} = UserRepo.list(0, 10)
      assert length(result) == 10
    end

    test "it returns an empty array" do
      assert {:ok, []} = UserRepo.list()
    end
  end

  describe "count/0" do
    test "it returns the whole table count" do
      for _ <- 0..39, do: user_fixture()
      {:ok, result} = UserRepo.count()
      assert result == 40
    end
  end
end
