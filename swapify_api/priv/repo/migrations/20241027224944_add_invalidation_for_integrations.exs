defmodule SwapifyApi.Repo.Migrations.AddInvalidationForIntegrations do
  use Ecto.Migration

  def change do
    alter table(:platform_connections) do
      add :platform_id, :text, null: false, default: fragment("gen_random_uuid()")
      add :invalidated_at, :utc_datetime, null: true
    end

    create unique_index(:platform_connections, [:platform_id, :name])
  end
end
