defmodule SwapifyApi.TransferRepoTest do
  alias SwapifyApi.MusicProviders.Playlist
  use SwapifyApi.DataCase

  alias SwapifyApi.Operations.Transfer
  alias SwapifyApi.Operations.TransferRepo
  alias SwapifyApi.Repo
  import SwapifyApi.AccountsFixtures
  import SwapifyApi.MusicProvidersFixtures
  import SwapifyApi.OperationsFixtures

  describe "create_or_update/3" do
    setup do
      user = user_fixture()
      playlist = playlist_fixture(%{user_id: user.id})
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
      playlist = playlist_fixture(%{user_id: user.id})
      transfer = transfer_fixture(%{user_id: user.id, source_playlist_id: playlist.id})
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
          user_id: user.id,
          source_playlist_id: playlist.id,
          matched_tracks: matched_tracks
        })

      assert {:ok, _} = TransferRepo.add_matched_tracks(transfer.id, new_matched_tracks)
      updated_transfer = Repo.reload(transfer)
      assert length(updated_transfer.matched_tracks) == 30
    end
  end

  describe "add_not_found_tracks/2" do
    setup do
      user = user_fixture()
      playlist = playlist_fixture(%{user_id: user.id})
      transfer = transfer_fixture(%{user_id: user.id, source_playlist_id: playlist.id})
      {:ok, user: user, playlist: playlist, transfer: transfer}
    end

    test "it should add tracks to the not_found_tracks json array", %{transfer: transfer} do
      tracks = 1..5 |> Enum.map(fn _ -> track_fixture() end)

      assert {:ok, _} = TransferRepo.add_not_found_tracks(transfer.id, tracks)
      updated_transfer = Repo.reload(transfer)
      assert length(updated_transfer.not_found_tracks) == 5
    end
  end

  describe "update/2" do
    setup do
      user = user_fixture()
      playlist = playlist_fixture(%{user_id: user.id})
      transfer = transfer_fixture(%{user_id: user.id, source_playlist_id: playlist.id})
      {:ok, user: user, playlist: playlist, transfer: transfer}
    end

    test "it should update an existing transfer", %{transfer: transfer, user: user} do
      %{id: job_id} = job_fixture(%{user_id: user.id})

      assert {:ok, %Transfer{matching_step_job_id: ^job_id}} =
               TransferRepo.update(transfer, %{
                 matching_step_job_id: job_id
               })
    end
  end

  describe "get_tranfer_by_step_and_id/2" do
    setup do
      user = user_fixture()
      playlist = playlist_fixture(%{user_id: user.id})
      {:ok, user: user, playlist: playlist}
    end

    test "it should return a transfer having a matching job done and other jobs not done", %{
      user: user,
      playlist: playlist
    } do
      matching_job = job_fixture(%{user_id: user.id, status: "done"})

      transfer =
        transfer_fixture(%{
          user_id: user.id,
          matching_step_job_id: matching_job.id,
          source_playlist_id: playlist.id
        })

      transfer_id = transfer.id

      {:ok, %Transfer{id: ^transfer_id}} =
        TransferRepo.get_transfer_by_step_and_id(transfer_id, :matching)
    end

    test "it should fail when trying to get a transfer in a matching state while the matching job is not done",
         %{
           user: user,
           playlist: playlist
         } do
      matching_job = job_fixture(%{user_id: user.id, status: "started"})

      transfer =
        transfer_fixture(%{
          user_id: user.id,
          matching_step_job_id: matching_job.id,
          source_playlist_id: playlist.id
        })

      transfer_id = transfer.id

      {:error, %ErrorMessage{code: :not_found}} =
        TransferRepo.get_transfer_by_step_and_id(transfer_id, :matching)
    end

    test "it should return a transfer having a matching job done and the transfer done",
         %{
           user: user,
           playlist: playlist
         } do
      matching_job = job_fixture(%{user_id: user.id, status: "done"})
      transfer_job = job_fixture(%{user_id: user.id, status: "done"})

      transfer =
        transfer_fixture(%{
          user_id: user.id,
          matching_step_job_id: matching_job.id,
          transfer_step_job_id: transfer_job.id,
          source_playlist_id: playlist.id
        })

      transfer_id = transfer.id

      {:ok, %Transfer{id: ^transfer_id}} =
        TransferRepo.get_transfer_by_step_and_id(transfer_id, :transfer)
    end

    test "it should fail when trying to get a transfer in a complete state without having the transfer step done",
         %{
           user: user,
           playlist: playlist
         } do
      matching_job = job_fixture(%{user_id: user.id, status: "done"})
      transfer_job = job_fixture(%{user_id: user.id, status: "started"})

      transfer =
        transfer_fixture(%{
          user_id: user.id,
          matching_step_job_id: matching_job.id,
          transfer_step_job_id: transfer_job.id,
          source_playlist_id: playlist.id
        })

      transfer_id = transfer.id

      {:error, %ErrorMessage{code: :not_found}} =
        TransferRepo.get_transfer_by_step_and_id(transfer_id, :transfer)
    end

    test "it should include the playlist in the transfer returned", %{
      user: user,
      playlist: playlist
    } do
      matching_job = job_fixture(%{user_id: user.id, status: "done"})
      transfer_job = job_fixture(%{user_id: user.id, status: "done"})

      transfer =
        transfer_fixture(%{
          user_id: user.id,
          matching_step_job_id: matching_job.id,
          transfer_step_job_id: transfer_job.id,
          source_playlist_id: playlist.id
        })

      {:ok, transfer} =
        TransferRepo.get_transfer_by_step_and_id(transfer.id, :transfer,
          includes: [:source_playlist]
        )

      assert %Playlist{} = transfer.source_playlist
    end
  end

  describe "get_transfer_infos/1" do
    setup do
      user = user_fixture()
      playlist = playlist_fixture(%{user_id: user.id})
      transfer = transfer_fixture(%{user_id: user.id, source_playlist_id: playlist.id})
      {:ok, user: user, playlist: playlist, transfer: transfer}
    end

    test "it should return the transfer infos", %{transfer: transfer} do
      transfer_id = transfer.id
      assert {:ok, %{id: ^transfer_id}} = TransferRepo.get_transfer_infos(transfer.id)
    end
  end
end
