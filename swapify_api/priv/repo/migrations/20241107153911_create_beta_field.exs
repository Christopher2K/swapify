defmodule SwapifyApi.Repo.Migrations.CreateBetaField do
  use Ecto.Migration

  def change do
    execute """
              CREATE TYPE user_role as ENUM (
                'beta',
                'user',
                'admin'
              )
            """,
            """
                  DROP TYPE user_role;
            """

    alter table(:users) do
      add :role, :user_role, null: false, default: "user"
    end
  end
end
