defmodule SwapifyApi.SignInUserTest do
  use SwapifyApi.DataCase

  import SwapifyApi.AccountsFixtures

  alias SwapifyApi.Accounts.Services.SignInUser

  test "it returns a user when email and psw are correct" do
    email = "chris@test.fr"
    password = "Password1234"

    user_fixture(%{
      email: email,
      password: password
    })

    assert {:ok, user, _, _} = SignInUser.call(email, password)
    assert user.email == email
    assert user.password != email
  end

  test "it fails when the psw is not the one expected" do
    email = "chris@test.fr"
    password = "Password1234"

    user_fixture(%{
      email: email,
      password: password
    })

    assert {:error, :unauthorized} = SignInUser.call(email, "fakepassword")
  end

  test "it fails when the email is not the one expected" do
    email = "chris@test.fr"
    password = "Password1234"

    user_fixture(%{
      email: email,
      password: password
    })

    assert {:error, :unauthorized} = SignInUser.call("fakeemail@test.fr", password)
  end
end
