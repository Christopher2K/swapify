defmodule SwapifyApi.EmailsTest do
  use ExUnit.Case

  describe "welcome/2" do
    test "it should render html" do
      assert %Swoosh.Email{to: [{"test", "test@test.fr"}]} =
               SwapifyApi.Emails.welcome("test@test.fr", "test",
                 app_url: "https://app.something",
                 username: "Username"
               )
    end
  end

  describe "transfer_ready/2" do
    test "it should render html" do
      assert %Swoosh.Email{to: [{"test", "test@test.fr"}]} =
               SwapifyApi.Emails.transfer_ready("test@test.fr", "test",
                 app_url: "https://app.something",
                 username: "Username",
                 source_name: "Spotify",
                 destination_name: "Apple Music",
                 matched_tracks_length: 10,
                 playlist_length: 100
               )
    end
  end

  describe "transfer_error/2" do
    test "it should render html" do
      assert %Swoosh.Email{to: [{"test", "test@test.fr"}]} =
               SwapifyApi.Emails.transfer_error("test@test.fr", "test",
                 app_url: "https://app.something",
                 username: "Username",
                 source_name: "Spotify",
                 destination_name: "Apple Music"
               )
    end
  end

  describe "transfer_done/2" do
    test "it should render html" do
      assert %Swoosh.Email{to: [{"test", "test@test.fr"}]} =
               SwapifyApi.Emails.transfer_done("test@test.fr", "test",
                 app_url: "https://app.something",
                 username: "Username",
                 source_name: "Spotify",
                 destination_name: "Apple Music"
               )
    end
  end

  describe "password_reset_request/2" do
    test "it should render html" do
      assert %Swoosh.Email{to: [{"test", "test@test.fr"}]} =
               SwapifyApi.Emails.password_reset_request("test@test.fr", "test",
                 username: "Username",
                 code: "1234"
               )
    end
  end
end
