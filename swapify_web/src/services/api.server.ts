import ky, { HTTPError, KyInstance } from "ky";
import { getRequestEvent } from "solid-js/web";

import { useSession } from "./session";

export const apiClient = ky.create({
  prefixUrl: import.meta.env.VITE_API_URL,
});

type RemoteData<T> = {
  data: T;
};

type RemoteArgs<T = void> = T extends void
  ? {
      client?: KyInstance;
    }
  : {
      client?: KyInstance;
      data: T;
    };

type SuccessResponse<T> = {
  status: "ok";
  data: T;
};

type ErrorResponse<T> = {
  status: "error";
  code?: number;
  data?: T;
};

type APIResponse<T, E = {}> = SuccessResponse<T> | ErrorResponse<E>;

async function wrapApiCall<T, E>(
  call: () => Promise<T>,
): Promise<APIResponse<T, E>> {
  try {
    const data = await call();
    return {
      status: "ok",
      data,
    };
  } catch (e) {
    if (e instanceof HTTPError) {
      let errorData;

      try {
        errorData = (await e.response.json()) as E;
      } catch {
        errorData = undefined;
      }

      return {
        status: "error",
        code: e.response.status,
        data: errorData,
      };
    } else {
      return {
        status: "error",
      };
    }
  }
}

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

type APIUser = {
  id: string;
  username: string;
  email: string;
  insertedAt: string;
  updatedAt: string;
};

type PostSignInArgs = RemoteArgs<SignInData>;
export type SignInData = { email: string; password: string };
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
