defmodule SwapifyApi.SpotifyAPIFixtures do
  def user_library_response_fixture() do
    %{
      "href" => "https://api.spotify.com/v1/me/shows?offset=0&limit=20",
      "limit" => 20,
      "next" => "https://api.spotify.com/v1/me/shows?offset=1&limit=1",
      "offset" => 0,
      "previous" => "https://api.spotify.com/v1/me/shows?offset=1&limit=1",
      "total" => 4,
      "items" => [
        %{
          "added_at" => "string",
          "track" => %{
            "album" => %{
              "album_type" => "compilation",
              "total_tracks" => 9,
              "available_markets" => ["CA", "BR", "IT"],
              "external_urls" => %{
                "spotify" => "string"
              },
              "href" => "string",
              "id" => "2up3OPMp9Tb4dAKM2erWXQ",
              "images" => [
                %{
                  "url" => "https://i.scdn.co/image/ab67616d00001e02ff9ca10b55ce82ae553c8228",
                  "height" => 300,
                  "width" => 300
                }
              ],
              "name" => "string",
              "release_date" => "1981-12",
              "release_date_precision" => "year",
              "restrictions" => %{
                "reason" => "market"
              },
              "type" => "album",
              "uri" => "spotify:album:2up3OPMp9Tb4dAKM2erWXQ",
              "artists" => [
                %{
                  "external_urls" => %{
                    "spotify" => "string"
                  },
                  "href" => "string",
                  "id" => "string",
                  "name" => "string",
                  "type" => "artist",
                  "uri" => "string"
                }
              ]
            },
            "artists" => [
              %{
                "external_urls" => %{
                  "spotify" => "string"
                },
                "href" => "string",
                "id" => "string",
                "name" => "string",
                "type" => "artist",
                "uri" => "string"
              }
            ],
            "available_markets" => ["string"],
            "disc_number" => 0,
            "duration_ms" => 0,
            "explicit" => false,
            "external_ids" => %{
              "isrc" => "string",
              "ean" => "string",
              "upc" => "string"
            },
            "external_urls" => %{
              "spotify" => "string"
            },
            "href" => "string",
            "id" => "string",
            "is_playable" => false,
            "linked_from" => %{},
            "restrictions" => %{
              "reason" => "string"
            },
            "name" => "string",
            "popularity" => 0,
            "preview_url" => "string",
            "track_number" => 0,
            "type" => "track",
            "uri" => "string",
            "is_local" => false
          }
        }
      ]
    }
  end

  def request_access_token_response_fixture(),
    do: %{
      "access_token" => "fake_at",
      "refresh_token" => "fake_rt",
      "expires_in" => 3600
    }

  def me_response_fixture(), do: %{"id" => "fake_id", "country" => "FR"}
end
