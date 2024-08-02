defmodule SwapifyApi.Repo.Migrations.CreatePlaylists do
  use Ecto.Migration

  def change do
    create table(:playlists, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :name, :string, null: true
      add :platform_name, :music_platforms, null: false
      add :is_library, :boolean, null: false, default: false
      add :user_id, references(:users, on_delete: :delete_all), null: false
      add :tracks, {:array, :map}, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
