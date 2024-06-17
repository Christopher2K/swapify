import ky from "ky";
import { wrapApiCall, RemoteArgs, RemoteData } from "./api.types";

const apiClient = ky.create({
  credentials: "include",
});

type GetAppleMusicLoginArgs = RemoteArgs<void>;
type AppleMusicLoginResponse = RemoteData<{ developerToken: string }>;
export function getAppleMusicLogin({
  client = apiClient,
}: GetAppleMusicLoginArgs) {
  return wrapApiCall(() =>
    client
      .get("/api/integrations/applemusic/login")
      .json<AppleMusicLoginResponse>(),
  );
}

type PostAppleMusicLoginCallbackArgs = RemoteArgs<{ authToken: string }>;
type AppleMusicLoginCallbackResponse = RemoteData<void>;
export function postAppleMusicLoginCallback({
  client = apiClient,
  data,
}: PostAppleMusicLoginCallbackArgs) {
  return wrapApiCall(() =>
    client
      .post("/api/integrations/applemusic/callback", { json: data })
      .json<AppleMusicLoginCallbackResponse>(),
  );
}
