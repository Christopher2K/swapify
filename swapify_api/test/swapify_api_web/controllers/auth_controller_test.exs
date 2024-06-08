defmodule SwapifyApiWeb.AuthControllerTest do
  use SwapifyApiWeb.ConnCase, async: true

  import SwapifyApi.AccountsFixtures

  describe "POST /api/signup" do
    test "it signs up a new user", %{conn: conn} do
      conn = post(conn, "/api/auth/signup", email: "chris@test.fr", password: "password1234")
      assert conn.status == 204
    end

    test "it fails when an user with this email already exists", %{conn: conn} do
      email = "chris@test.fr"
      user_fixture(%{email: email})

      conn = post(conn, "/api/auth/signup", email: email, password: "password1234")

      assert conn.status == 422
    end
  end
end
