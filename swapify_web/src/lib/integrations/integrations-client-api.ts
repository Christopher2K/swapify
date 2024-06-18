import { clientApiClient } from "#root/lib/api/client";
import { wrapApiCall } from "#root/lib/api/utils";
import type { RemoteArgs, RemoteData } from "#root/lib/api/types";

type GetAppleMusicLoginArgs = RemoteArgs<void>;
type AppleMusicLoginResponse = RemoteData<{ developerToken: string }>;
export function getAppleMusicLogin({
  client = clientApiClient,
}: GetAppleMusicLoginArgs) {
  return wrapApiCall(() =>
    client
      .get("/api/integrations/applemusic/login")
      .json<AppleMusicLoginResponse>(),
  );
}

type PostAppleMusicLoginCallbackArgs = RemoteArgs<{ authToken: string }>;
type AppleMusicLoginCallbackResponse = RemoteData<"ok">;
export function postAppleMusicLoginCallback({
  client = clientApiClient,
  data,
}: PostAppleMusicLoginCallbackArgs) {
  return wrapApiCall(() =>
    client
      .post("/api/integrations/applemusic/callback", { json: data })
      .json<AppleMusicLoginCallbackResponse>(),
  );
}
