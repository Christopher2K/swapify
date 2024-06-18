import { getRequestEvent } from "solid-js/web";
import { cache, createAsync, redirect } from "@solidjs/router";

import { getMe } from "./auth-server-api";
import { useSession } from "./session";

export const getCurrentUser = cache(async () => {
  "use server";
  const request = getRequestEvent()!;
  const session = await useSession(request?.nativeEvent);
  if (session.data.auth) {
    const data = await getMe();
    if (data.status === "error") {
      await session.clear();
      return undefined;
    } else {
      return data;
    }
  }

  return undefined;
}, "getCurrentUser");

const anonymousRouteCheck = async () => {
  "use server";
  const request = getRequestEvent()!;
  const session = await useSession(request?.nativeEvent);

  if (session.data.auth) {
    throw redirect("/app");
  }
};

export const createAnonymousRouteCheck = () =>
  createAsync(() => anonymousRouteCheck());

const protectedRouteCheck = cache(async () => {
  "use server";
  const request = getRequestEvent()!;
  const session = await useSession(request?.nativeEvent);

  if (!session.data.auth) {
    throw redirect("/signin");
  }
  return {};
}, "protectedRouteCheck");

export const createProtectedRouteCheck = () =>
  createAsync(() => protectedRouteCheck());
