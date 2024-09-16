defmodule SwapifyApi.Repo.Migrations.CreateJobs do
  use Ecto.Migration

  def change do
    execute """
            CREATE TYPE job_status as ENUM (
              'started',
              'done',
              'error'
            );
            """,
            """
            DROP TYPE job_status;
            """

    create table(:jobs, primary_key: false) do
      add :id, :binary_id, primary_key: true, default: fragment("gen_random_uuid()")
      add :name, :string, null: false
      add :status, :job_status, null: false, default: "started"
      add :oban_job_args, :jsonb, null: false

      add :user_id, references(:users, on_delete: :nilify_all), null: true

      timestamps(type: :utc_datetime)
    end
  end
end
