defmodule SwapifyApi.Repo.Migrations.CreatePasswordResetRequests do
  use Ecto.Migration

  def change do
    create table(:password_reset_requests, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :code, :string, length: 21, null: false
      add :is_used, :boolean, default: false

      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:password_reset_requests, [:code])
  end
end
