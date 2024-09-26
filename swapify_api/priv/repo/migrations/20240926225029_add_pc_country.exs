defmodule SwapifyApi.Repo.Migrations.AddPcCountry do
  use Ecto.Migration

  def change do
    alter table(:platform_connections) do
      add :country_code, :string, null: true, size: 4
    end
  end
end
