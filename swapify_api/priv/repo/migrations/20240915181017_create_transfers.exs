defmodule SwapifyApi.Repo.Migrations.CreateTransfers do
  use Ecto.Migration

  def change do
    create table(:transfers, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :destination, :music_platforms, null: false
      add :matched_tracks, :jsonb, null: false, default: "[]"

      add :matching_step_job_id, references(:jobs, on_delete: :nilify_all), null: true
      add :pre_transfer_step_job_id, references(:jobs, on_delete: :nilify_all), null: true
      add :transfer_step_job_id, references(:jobs, on_delete: :nilify_all), null: true

      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :source_playlist_id, references(:playlists, on_delete: :nilify_all), null: true

      timestamps(type: :utc_datetime)
    end
  end
end
