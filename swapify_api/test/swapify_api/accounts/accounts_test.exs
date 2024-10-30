defmodule SwapifyApi.SignInUserTest do
  use SwapifyApi.DataCase
  alias SwapifyApi.Accounts.PlatformConnection

  import SwapifyApi.AccountsFixtures

  alias SwapifyApi.Accounts
  alias SwapifyApi.ExternalAPITools
  alias SwapifyApi.SpotifyAPIFixtures
  alias SwapifyApi.AppleMusicAPIFixtures

  describe "create_or_update_integration/2" do
    setup ctx do
      ExternalAPITools.handle_mocked_response(ctx)
      user = user_fixture()
      {:ok, user: user}
    end

    @tag mocked_responses: [
           %{
             host: "accounts.spotify.com",
             path: "/api/token",
             body: SpotifyAPIFixtures.request_access_token_response_fixture(),
             status: 200
           },
           %{
             host: "api.spotify.com",
             path: "/v1/me",
             body: SpotifyAPIFixtures.me_response_fixture(),
             status: 200
           }
         ]
    test "it creates a new spotify integration", %{user: user} do
      assert {:ok,
              %PlatformConnection{
                name: :spotify,
                access_token: "fake_at",
                refresh_token: "fake_rt",
                country_code: "FR"
              }} =
               Accounts.create_or_update_integration(:spotify,
                 code: "code",
                 session_state: "session_state",
                 user_id: user.id,
                 remote_state: "session_state"
               )
    end

    @tag mocked_responses: [
           %{
             host: "api.music.apple.com",
             path: "/v1/me/storefront",
             body: AppleMusicAPIFixtures.me_storefront_response_fixture(),
             status: 200
           }
         ]
    test "it creates a new apple music integration", %{user: user} do
      assert {:ok,
              %PlatformConnection{
                name: :applemusic,
                access_token: "fake_at",
                refresh_token: nil,
                country_code: "FR"
              }} =
               Accounts.create_or_update_integration(:applemusic,
                 user_id: user.id,
                 token: "fake_at"
               )
    end

    @tag mocked_responses: [
           %{
             host: "accounts.spotify.com",
             path: "/api/token",
             body: %{"error" => "invalid_grant"},
             status: 400
           }
         ]
    test "it returns an error when the spotify api returns an error", %{user: user} do
      assert {:error, _} =
               Accounts.create_or_update_integration(:spotify,
                 user_id: user.id,
                 session_state: "SESSION_STATE",
                 remote_state: "SESSION_STATE",
                 code: "code"
               )
    end

    @tag mocked_responses: [
           %{
             host: "api.music.apple.com",
             path: "/v1/me/storefront",
             status: 400
           }
         ]
    test "it returns an error when the apple music api returns an error", %{user: user} do
      assert {:error, _} =
               Accounts.create_or_update_integration(:applemusic,
                 user_id: user.id,
                 token: "token"
               )
    end

    @tag mocked_responses: [
           %{
             host: "accounts.spotify.com",
             path: "/api/token",
             body: SpotifyAPIFixtures.request_access_token_response_fixture(),
             status: 200
           },
           %{
             host: "api.spotify.com",
             path: "/v1/me",
             body: SpotifyAPIFixtures.me_response_fixture(),
             status: 200
           }
         ]
    test "it should refresh an existing spotify integration for a user", %{user: user} do
      %{id: pc_id} = platform_connection_fixture(%{name: :spotify, user_id: user.id})

      assert {:ok,
              %PlatformConnection{
                id: ^pc_id,
                name: :spotify,
                access_token: "fake_at",
                refresh_token: "fake_rt"
              }} =
               Accounts.create_or_update_integration(:spotify,
                 user_id: user.id,
                 session_state: "session_state",
                 remote_state: "session_state",
                 code: "code"
               )
    end

    @tag mocked_responses: [
           %{
             host: "api.music.apple.com",
             path: "/v1/me/storefront",
             body: AppleMusicAPIFixtures.me_storefront_response_fixture(),
             status: 200
           }
         ]
    test "it should refresh an existing apple music integration for a user", %{user: user} do
      %{id: pc_id} = platform_connection_fixture(%{name: :applemusic, user_id: user.id})

      assert {:ok,
              %PlatformConnection{
                id: ^pc_id,
                name: :applemusic,
                access_token: "new_token"
              }} =
               Accounts.create_or_update_integration(:applemusic,
                 user_id: user.id,
                 token: "new_token"
               )
    end
  end

  describe "sign_in_user/2" do
    test "it returns a user when email and psw are correct" do
      email = "chris@test.fr"
      password = "Password1234"

      user_fixture(%{
        email: email,
        password: password
      })

      assert {:ok, user, _, _} = Accounts.sign_in_user(email, password)
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

      assert {:error, :auth_failed} = Accounts.sign_in_user(email, "fakepassword")
    end

    test "it fails when the email is not the one expected" do
      email = "chris@test.fr"
      password = "Password1234"

      user_fixture(%{
        email: email,
        password: password
      })

      assert {:error, :auth_failed} = Accounts.sign_in_user("fakeemail@test.fr", password)
    end
  end

  describe "disable_partner_integration/2" do
    setup do
      user = user_fixture()
      pc = platform_connection_fixture(%{user_id: user.id, name: :spotify})
      {:ok, user: user}
    end

    test "it should disable a partner integration", %{user: user} do
      assert {:ok, pc} =
               Accounts.disable_partner_integration(user.id, :spotify)

      assert not is_nil(pc.invalidated_at)
    end
  end
end
