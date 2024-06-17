import ky from "ky";
import { getRequestEvent } from "solid-js/web";

import { useSession } from "./session";
import { wrapApiCall, RemoteArgs, RemoteData, APIUser } from "./api.types";

const apiClient = ky.create({
  prefixUrl: import.meta.env.VITE_API_URL,
});

async function getAuthHeaders() {
  "use server";
  const request = getRequestEvent()!;
  const session = await useSession(request.nativeEvent);

  if (session.data.auth) {
    return {
      authorization: "Bearer " + session.data.auth.accessToken,
    };
  } else {
    return {};
  }
}

type PostSignInArgs = RemoteArgs<{ email: string; password: string }>;
type SignInResponse = RemoteData<{
  accessToken: string;
  refreshToken: string;
  user: APIUser;
}>;
export function postSignIn({ client = apiClient, data }: PostSignInArgs) {
  "use server";
  return wrapApiCall(() =>
    client.post("api/auth/signin", { json: data }).json<SignInResponse>(),
  );
}

type PostSignUpArgs = RemoteArgs<{
  email: string;
  password: string;
  username: string;
}>;
type SignUpResponse = RemoteData<void>;
export function postSignUp({ client = apiClient, data }: PostSignUpArgs) {
  "use server";
  return wrapApiCall(() =>
    client.post("api/auth/signup", { json: data }).json<SignUpResponse>(),
  );
}

type GetMeResponse = RemoteData<APIUser>;
export async function getMe({ client = apiClient }: RemoteArgs = {}) {
  "use server";
  const headers = await getAuthHeaders();
  return wrapApiCall(() =>
    client
      .get("api/users/me", {
        headers,
      })
      .json<GetMeResponse>(),
  );
}
