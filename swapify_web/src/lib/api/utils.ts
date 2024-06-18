import { HTTPError } from "ky";
import { getRequestEvent } from "solid-js/web";

import { useSession } from "#root/lib/auth/session";

import { APIResponse } from "./types";

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

export async function getServerAuthHeaders() {
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
