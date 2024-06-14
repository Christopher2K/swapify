defmodule SwapifyApi.MusicProviders.AppleMusicDeveloperToken do
  alias JOSE.JWK
  alias JOSE.JWS

  # in seconds
  @default_token_validity 5400

  @doc """
  Generate an Apple Music Developer Token.
  Crash on error, since this is supposed to work for the app to function
  Options:
  - token_validity -> Token validity in seconds
  """
  @spec create!() :: String.t()
  def create!(opts \\ []) do
    token_validity = opts |> Keyword.get(:token_validity, @default_token_validity)

    config = Application.fetch_env!(:swapify_api, SwapifyApi.MusicProviders.AppleMusic)

    team_id = config |> Keyword.get(:team_id)
    key_id = config |> Keyword.get(:key_id)
    private_key = config |> Keyword.get(:private_key)

    now = DateTime.utc_now()
    iat = now |> DateTime.to_unix()
    exp = now |> DateTime.add(token_validity, :second) |> DateTime.to_unix()

    jwk = JWK.from_pem(private_key)
    jws = %{"alg" => "ES256", "kid" => key_id}
    payload = %{"iss" => team_id, "iat" => iat, "exp" => exp} |> Jason.encode!()

    jwk |> JWS.sign(payload, jws) |> JWS.compact() |> elem(1)
  end
end
