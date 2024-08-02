defmodule SwapifyApi.AppleMusicAPIFixtures do
  def user_library_response_fixture() do
    %{
      "data" => [
        %{
          "id" => "i.LxcKpzFPMJnJwX",
          "type" => "library-songs",
          "href" => "/v1/me/library/songs/i.LxcKpzFPMJnJwX",
          "attributes" => %{
            "albumName" => "1989",
            "artistName" => "Taylor Swift",
            "artwork" => %{
              "width" => 1400,
              "height" => 1400,
              "url" => "https://example.com/artwork/1400x1400.jpg"
            },
            "contentRating" => "clean",
            "discNumber" => 1,
            "durationInMillis" => 231_827,
            "genreNames" => [
              "Pop"
            ],
            "hasLyrics" => true,
            "isrc" => "USCJY1431238",
            "name" => "Shake It Off",
            "playParams" => %{
              "id" => "i.LxcKpzFPMJnJwX",
              "kind" => "song"
            },
            "releaseDate" => "2014-08-18",
            "trackNumber" => 6,
            "url" => "https://music.apple.com/us/song/shake-it-off/1440818542"
          },
          "relationships" => %{
            "catalog" => %{
              "data" => [
                %{
                  "id" => "902273725",
                  "type" => "songs",
                  "href" => "/v1/catalog/us/songs/902273725",
                  "attributes" => %{
                    "previews" => [
                      %{
                        "url" =>
                          "https://audio-ssl.itunes.apple.com/itunes-assets/AudioPreview118/v4/4d/80/bb/4d80bb0d-5b66-7c09-056c-4dbae131e0c4/mzaf_6323814923022681502.plus.aac.p.m4a"
                      }
                    ],
                    "artwork" => %{
                      "width" => 1400,
                      "height" => 1400,
                      "url" =>
                        "https://is1-ssl.mzstatic.com/image/thumb/Music118/v4/49/09/ff/4909ffd6-9051-94c3-43a8-22c6648ba3be/00602547025906.rgb.jpg/{w}x{h}bb.jpg"
                    },
                    "artistName" => "Taylor Swift",
                    "url" => "https://music.apple.com/us/song/shake-it-off/902273725",
                    "discNumber" => 1,
                    "genreNames" => [
                      "Pop"
                    ],
                    "durationInMillis" => 219_200,
                    "releaseDate" => "2014-08-18",
                    "name" => "Shake It Off",
                    "isrc" => "USCJY1431238",
                    "hasLyrics" => true,
                    "albumName" => "1989",
                    "playParams" => %{
                      "id" => "902273725",
                      "kind" => "song"
                    },
                    "trackNumber" => 6,
                    "composerName" => "Taylor Swift, Max Martin & Shellback"
                  }
                }
              ]
            }
          }
        }
      ],
      "next" => "/v1/me/library/songs?offset=25&include=catalog"
    }
  end
end
