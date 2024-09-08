defmodule SwapifyApi.Repo.Migrations.CreatePlaylists do
  use Ecto.Migration

  def change do
    execute """
            CREATE TYPE sync_status as ENUM (
              'unsynced',
              'syncing',
              'synced',
              'error'
            );
            """,
            """
            DROP TYPE sync_status;
            """

    create table(:playlists, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :name, :string, null: true
      add :platform_id, :string, null: false
      add :platform_name, :music_platforms, null: false
      add :tracks, :jsonb, null: false, default: "[]"
      add :tracks_total, :integer, null: true
      add :sync_status, :sync_status, null: false, default: "unsynced"

      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:playlists, [:user_id, :platform_id, :platform_name])
  end
end
