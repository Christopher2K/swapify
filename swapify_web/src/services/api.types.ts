import { KyInstance, HTTPError } from "ky";

export type RemoteData<T> = {
  data: T;
};

export type RemoteArgs<T = void> = T extends void
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

export type APIResponse<T, E = {}> = SuccessResponse<T> | ErrorResponse<E>;

export async function wrapApiCall<T, E>(
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

// API OBJECT TYPES
export type APIUser = {
  id: string;
  username: string;
  email: string;
  insertedAt: string;
  updatedAt: string;
};
