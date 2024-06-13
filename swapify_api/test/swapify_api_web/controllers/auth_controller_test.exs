defmodule SwapifyApiWeb.AuthControllerTest do
  use SwapifyApiWeb.ConnCase, async: true

  import SwapifyApi.AccountsFixtures

  describe "POST /api/auth/signup" do
    test "it signs up a new user", %{conn: conn} do
      conn =
        post(conn, "/api/auth/signup",
          email: "chris@test.fr",
          password: "password1234",
          username: "chris"
        )

      assert conn.status == 204
    end

    test "it fails when an user with this email already exists", %{conn: conn} do
      email = "chris@test.fr"
      user_fixture(%{email: email})

      conn =
        post(conn, "/api/auth/signup", email: email, password: "password1234", username: "chris")

      assert conn.status == 422
    end
  end

  describe "POST /api/auth/signin" do
    setup do
      email = "chris@test.fr"
      password = "Password1234"

      user_fixture(%{email: email, password: password})
      {:ok, email: email, password: password}
    end

    test "it signs in an existing user", %{conn: conn, email: email, password: password} do
      conn = post(conn, "/api/auth/signin", email: email, password: password)
      assert conn.status == 200
    end

    test "it rejects a non existing user", %{conn: conn, password: password} do
      conn = post(conn, "/api/auth/signin", email: "no@body.fr", password: password)
      assert conn.status == 401
    end
  end
end
