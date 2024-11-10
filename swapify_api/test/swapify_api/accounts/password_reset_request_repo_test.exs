defmodule SwapifyApi.PasswordResetRequestRepoTest do
  use SwapifyApi.DataCase

  alias SwapifyApi.Accounts.PasswordResetRequestRepo
  alias SwapifyApi.Accounts.PasswordResetRequest

  import SwapifyApi.AccountsFixtures

  describe "get_by_code/1" do
    test "it should return a password reset request by its code" do
      user = user_fixture()

      %{code: code} = password_reset_request_fixture(%{"user_id" => user.id})

      assert {:ok, %PasswordResetRequest{code: ^code}} =
               PasswordResetRequestRepo.get_by_code(code)
    end
  end

  describe "create/1" do
    test "it should create a new password reset request" do
      user = user_fixture()

      assert {:ok, %PasswordResetRequest{}} =
               PasswordResetRequestRepo.create(user.id)
    end
  end

  describe "mark_as_used/1" do
    test "it should mark a password reset request as used" do
      user = user_fixture()
      password_reset_request = password_reset_request_fixture(%{"user_id" => user.id})

      assert {1, nil} =
               PasswordResetRequestRepo.mark_as_used(password_reset_request.code)

      %{is_used: is_used} = SwapifyApi.Repo.reload(password_reset_request)

      assert is_used
    end
  end
end
