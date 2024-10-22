defmodule SwapifyApi.ValuesFixtures do
  @random_platform_values [:applemusic, :spotify]
  def random_platform_name(),
    do:
      Enum.at(
        @random_platform_values,
        Faker.random_between(0, length(@random_platform_values) - 1)
      )

  @random_playlist_status_values [:unsynced, :syncing, :synced, :error]
  def random_playlist_status(),
    do:
      Enum.at(
        @random_playlist_status_values,
        Faker.random_between(0, length(@random_playlist_status_values) - 1)
      )

  @random_job_status_values [:started, :done, :error, :canceled]
  def random_job_status(),
    do:
      Enum.at(
        @random_job_status_values,
        Faker.random_between(0, length(@random_job_status_values) - 1)
      )
end
