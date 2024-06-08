defmodule SwapifyApi.Repo.Migrations.CreatePlatformConnection do
  use Ecto.Migration

  def change do
    execute """
            CREATE TYPE music_platforms as ENUM (
              'spotify',
              'applemusic'
            );
            """,
            """
            DROP TYPE music_platforms;
            """

    create table(:platform_connections, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :name, :music_platforms, null: false
      add :access_token, :string, null: true, default: nil
      add :refresh_token, :string, null: true, default: nil

      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:platform_connections, [:user_id, :name])
  end
end
