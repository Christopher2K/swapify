import ky, { HTTPError, KyInstance } from "ky";

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

type APIUser = {
  id: string;
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
  return wrapApiCall(() =>
    client.post("api/auth/signin", { json: data }).json<SignInResponse>(),
  );
}

type GetMeResponse = RemoteData<APIUser>;
export function getMe({ client = apiClient }: RemoteArgs) {
  return wrapApiCall(() => client.get("api/users/me").json<GetMeResponse>());
}
