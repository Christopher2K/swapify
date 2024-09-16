defmodule SwapifyApi.TransferRepoTest do
  use SwapifyApi.DataCase

  alias SwapifyApi.Tasks.Transfer
  alias SwapifyApi.Tasks.TransferRepo
  alias SwapifyApi.Repo

  import SwapifyApi.AccountsFixtures
  import SwapifyApi.MusicProvidersFixtures
  import SwapifyApi.ValuesFixtures
  import SwapifyApi.TasksFixtures

  describe "create_or_update/3" do
    setup do
      user = user_fixture()
      playlist = playlist_fixture(%{"user_id" => user.id})
      {:ok, user: user, playlist: playlist}
    end

    test "it should create a transfer with the minimal amount of required data", %{
      playlist: playlist,
      user: user
    } do
      assert {:ok, %Transfer{}} =
               TransferRepo.create(%{
                 "destination" => :spotify,
                 "source_playlist_id" => playlist.id,
                 "user_id" => user.id
               })
    end
  end

  describe "add_matched_tracks/2" do
    setup do
      user = user_fixture()
      playlist = playlist_fixture(%{"user_id" => user.id})
      transfer = transfer_fixture(%{"user_id" => user.id, "source_playlist_id" => playlist.id})
      {:ok, user: user, playlist: playlist, transfer: transfer}
    end

    test "it should add tracks to a transfer without matched tracks", %{transfer: transfer} do
      new_matched_tracks = 1..5 |> Enum.map(fn _ -> matched_track_fixture() end)
      assert {:ok, _} = TransferRepo.add_matched_tracks(transfer.id, new_matched_tracks)
      updated_transfer = Repo.reload(transfer)
      assert length(updated_transfer.matched_tracks) == 5
    end

    test "it should add tracks to a transfer with existing matched tracks", %{
      playlist: playlist,
      user: user
    } do
      matched_tracks = 1..5 |> Enum.map(fn _ -> matched_track_fixture() |> Map.from_struct() end)
      new_matched_tracks = 1..25 |> Enum.map(fn _ -> matched_track_fixture() end)

      transfer =
        transfer_fixture(%{
          "user_id" => user.id,
          "source_playlist_id" => playlist.id,
          "matched_tracks" => matched_tracks
        })

      assert {:ok, _} = TransferRepo.add_matched_tracks(transfer.id, new_matched_tracks)
      updated_transfer = Repo.reload(transfer)
      assert length(updated_transfer.matched_tracks) == 30
    end
  end

  describe "update/2" do
    setup do
      user = user_fixture()
      playlist = playlist_fixture(%{"user_id" => user.id})
      transfer = transfer_fixture(%{"user_id" => user.id, "source_playlist_id" => playlist.id})
      {:ok, user: user, playlist: playlist, transfer: transfer}
    end

    test "it should update an existing transfer", %{transfer: transfer, user: user} do
      %{id: job_id} = job_fixture(%{"user_id" => user.id})

      assert {:ok, %Transfer{matching_step_job_id: ^job_id}} =
               TransferRepo.update(transfer, %{
                 "matching_step_job_id" => job_id
               })
    end
  end
end
