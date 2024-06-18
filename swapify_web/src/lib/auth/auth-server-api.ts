"use server";

import { serverApiClient } from "#root/lib/api/client";
import type { RemoteArgs, RemoteData } from "#root/lib/api/types";
import { wrapApiCall, getServerAuthHeaders } from "#root/lib/api/utils";

import type { APIUser } from "./auth-models";

type PostSignInArgs = RemoteArgs<{ email: string; password: string }>;
type SignInResponse = RemoteData<{
  accessToken: string;
  refreshToken: string;
  user: APIUser;
}>;
export function postSignIn({ client = serverApiClient, data }: PostSignInArgs) {
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
export function postSignUp({ client = serverApiClient, data }: PostSignUpArgs) {
  return wrapApiCall(() =>
    client.post("api/auth/signup", { json: data }).json<SignUpResponse>(),
  );
}

type GetMeResponse = RemoteData<APIUser>;
export async function getMe({ client = serverApiClient }: RemoteArgs = {}) {
  const headers = await getServerAuthHeaders();
  return wrapApiCall(() =>
    client
      .get("api/users/me", {
        headers,
      })
      .json<GetMeResponse>(),
  );
}
