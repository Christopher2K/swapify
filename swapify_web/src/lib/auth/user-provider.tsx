import { createContext, ParentProps, useContext } from "solid-js";
import { createAsync } from "@solidjs/router";

import { getCurrentUser } from "#root/lib/auth/auth-services";

const UserContext = createContext<
  () => Awaited<ReturnType<typeof getCurrentUser> | undefined>
>(() => undefined);

export function UserProvider(props: ParentProps) {
  const user = createAsync(() => getCurrentUser());

  return (
    <UserContext.Provider value={user}>{props.children}</UserContext.Provider>
  );
}

export function useUser() {
  return useContext(UserContext);
}
