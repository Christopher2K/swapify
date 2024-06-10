defmodule SwapifyApiWeb.UserControllerTest do
  use SwapifyApiWeb.ConnCase, async: true

  describe "GET /api/users/me" do
    @tag user: %{}
    test "it returns the profile of a single user", %{conn: conn} do
      conn = get(conn, "/api/users/me")
      assert conn.status == 200
    end

    test "it fails when the request is unauthenticated", %{conn: conn} do
      conn = get(conn, "/api/users/me")
      assert conn.status == 401
    end
  end
end
