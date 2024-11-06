defmodule SwapifyApi.PlatformConnectionTest do
  use SwapifyApi.DataCase

  alias SwapifyApi.Accounts.PlatformConnection
  alias SwapifyApi.Accounts.PlatformConnectionRepo

  import SwapifyApi.AccountsFixtures

  describe "create_or_update/3" do
    setup do
      user = user_fixture()
      {:ok, user: user}
    end

    test "it creates a new platform connection", %{user: user} do
      assert {:ok, %PlatformConnection{}, :created} =
               PlatformConnectionRepo.create_or_update(user.id, :spotify, %{
                 "access_token_exp" => DateTime.utc_now() |> DateTime.add(3600, :second),
                 "access_token" => "fake_at",
                 "country_code" => "FR",
                 "refresh_token" => "fake_rt"
               })
    end

    test "it updates an existing platform connection", %{user: user} do
      %{id: pc_id, name: pc_name} = platform_connection_fixture(%{user_id: user.id})

      assert {:ok, %PlatformConnection{id: ^pc_id}, :updated} =
               PlatformConnectionRepo.create_or_update(user.id, pc_name, %{
                 "access_token" => "fake_at"
               })
    end
  end
end
