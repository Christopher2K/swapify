defmodule SwapifyApi.Repo.Migrations.AddOptionalSpotifyEmail do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :spotify_account_email, :string, null: true
    end
  end
end
