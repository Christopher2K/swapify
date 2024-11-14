defmodule SwapifyApi.ScenarioFixtures do
  import SwapifyApi.AccountsFixtures
  import SwapifyApi.MusicProvidersFixtures

  @doc """
  User + PlatformConnection + Music Libraries
  """
  def new_user_with_all_music_providers_enabled_with_libraries() do
    user = user_fixture()
    spotify_pc = platform_connection_fixture(%{user_id: user.id, name: :spotify})
    apple_music_pc = platform_connection_fixture(%{user_id: user.id, name: :applemusic})

    spotify_library =
      playlist_fixture(%{
        user_id: user.id,
        platform_name: :spotify,
        platform_id: user.id
      })

    am_library =
      playlist_fixture(%{
        user_id: user.id,
        platform_name: :applemusic,
        platform_id: user.id
      })

    {:ok,
     user: user,
     spotify_pc: spotify_pc,
     am_pc: apple_music_pc,
     spotify_library: spotify_library,
     am_library: am_library}
  end
end
