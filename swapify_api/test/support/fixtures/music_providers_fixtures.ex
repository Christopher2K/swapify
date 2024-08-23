defmodule SwapifyApi.MusicProvidersFixtures do
  @moduledoc "Fixture related to the music providers context"

  alias SwapifyApi.Repo
  alias SwapifyApi.MusicProviders.Playlist
  alias SwapifyApi.MusicProviders.Track

  def playlist_fixture(attrs \\ %{}) do
    attrs =
      attrs
      |> Enum.into(%{
        user_id: Faker.UUID.v4(),
        name: Faker.Internet.user_name(),
        platform_name: "spotify",
        platform_id: Faker.UUID.v4(),
        tracks_total: 0,
        sync_status: :syncing
      })

    {:ok, playlist} =
      %Playlist{}
      |> Playlist.changeset(attrs)
      |> Repo.insert()

    playlist
  end

  def track_fixture(attrs \\ %{}, opts \\ []) do
    as_track_struct? = Keyword.get(opts, :as_struct, false)

    attrs =
      attrs
      |> Enum.into(%{
        "isrc" => Faker.UUID.v4(),
        "name" => Faker.Lorem.sentence(),
        "artists" => [Faker.Person.first_name()],
        "album" => Faker.Lorem.sentence()
      })

    if as_track_struct? do
      {:ok, track} =
        %Track{}
        |> Track.changeset(attrs)
        |> Ecto.Changeset.apply_action(:insert)

      track
    else
      attrs
    end
  end
end
