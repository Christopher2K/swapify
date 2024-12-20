defmodule SwapifyApiWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common data structures and query the data layer.

  Finally, if the test case interacts with the database,
  we enable the SQL sandbox, so changes done to the database
  are reverted at the end of every test. If you are using
  PostgreSQL, you can even run database tests asynchronously
  by setting `use SwapifyApiWeb.ConnCase, async: true`, although
  this option is not recommended for other databases.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # The default endpoint for testing
      @endpoint SwapifyApiWeb.Endpoint

      use SwapifyApiWeb, :verified_routes

      # Import conveniences for testing with connections
      import Plug.Conn
      import Phoenix.ConnTest
      import SwapifyApiWeb.ConnCase
    end
  end

  setup tags do
    SwapifyApi.DataCase.setup_sandbox(tags)

    user_attributes = tags[:user]

    if user_attributes do
      user = SwapifyApi.AccountsFixtures.user_fixture(user_attributes)
      {:ok, _, access, refresh} = SwapifyApi.Accounts.genereate_auth_tokens(user)

      conn =
        Phoenix.ConnTest.build_conn()
        |> Plug.Session.call(
          Plug.Session.init(
            store: :cookie,
            key: "_swapify_api_key",
            signing_salt: "zNobAVSf",
            same_site: "Lax"
          )
        )
        |> Plug.Conn.fetch_session()
        |> Plug.Conn.put_session(:access_token, access)
        |> Plug.Conn.put_session(:refresh_token, refresh)

      {:ok, conn: conn, access_token: access, refresh_token: refresh, user: user}
    else
      {:ok, conn: Phoenix.ConnTest.build_conn()}
    end
  end
end
