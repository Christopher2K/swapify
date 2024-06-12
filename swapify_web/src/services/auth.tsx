import { createContext, ParentProps, useContext } from "solid-js";
import { getRequestEvent } from "solid-js/web";
import { cache, createAsync, redirect } from "@solidjs/router";

import { useSession } from "#root/services/session";

import { getMe } from "./api.server";

export const getUser = cache(async () => {
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
}, "getUser");

type Awaited<T> = T extends Promise<infer R> ? R : T;

const UserContext = createContext<
  () => Awaited<ReturnType<typeof getMe> | undefined>
>(() => undefined);

export function UserProvider(props: ParentProps) {
  const user = createAsync(() => getUser());

  return (
    <UserContext.Provider value={user}>{props.children}</UserContext.Provider>
  );
}

export function useUser() {
  return useContext(UserContext);
}

const _anonymousRouteCheck = cache(async () => {
  "use server";
  const request = getRequestEvent()!;
  const session = await useSession(request?.nativeEvent);

  if (session.data.auth) {
    throw redirect("/app");
  }
}, "anonymousRouteCheck");
export const createAnonymousRouteCheck = () =>
  createAsync(() => _anonymousRouteCheck());

const _protectedRouteCheck = cache(async () => {
  "use server";
  const request = getRequestEvent()!;
  const session = await useSession(request?.nativeEvent);

  if (!session.data.auth) {
    throw redirect("/signin");
  }
}, "protectedRouteCheck");

export const createProtectedRouteCheck = () =>
  createAsync(() => _protectedRouteCheck());
