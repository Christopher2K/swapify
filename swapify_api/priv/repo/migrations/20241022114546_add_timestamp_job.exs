defmodule SwapifyApi.Repo.Migrations.AddTimestampJob do
  use Ecto.Migration

  def change do
    execute """
      ALTER TYPE job_status ADD VALUE IF NOT EXISTS 'canceled';
    """

    alter table(:jobs) do
      add :done_at, :utc_datetime, null: true
      add :canceled_at, :utc_datetime, null: true
    end
  end
end
