import { type PropsWithChildren, createContext, useContext } from "react";
import { useNavigate } from "@tanstack/react-router";

import { APIUser } from "#root/services/api.types";

import { useUserQuery } from "./hooks/use-user-query";

const AuthenticatedUserCtx = createContext<APIUser | null>(null);
function AuthenticatedUserProvider({
  children,
  user,
}: PropsWithChildren<{ user: APIUser }>) {
  return (
    <AuthenticatedUserCtx.Provider value={user}>
      {children}
    </AuthenticatedUserCtx.Provider>
  );
}
export function useAuthenticatedUser() {
  const ctx = useContext(AuthenticatedUserCtx);
  if (ctx == null) {
    throw new Error(
      "useAuthenticatedUserProvider must be used within a AuthenticatedUserProvider",
    );
  }
  return ctx;
}

export type AuthenticationProviderProps = PropsWithChildren;

export function AuthenticationProvider({
  children,
}: AuthenticationProviderProps) {
  const { user, isError } = useUserQuery();
  const navigate = useNavigate();

  if (isError) {
    queueMicrotask(() => {
      navigate({ to: "/signin", replace: true });
    });
  }

  if (user != null) {
    return (
      <AuthenticatedUserProvider user={user}>
        {children}
      </AuthenticatedUserProvider>
    );
  }

  return <h1>Loading...</h1>;
}
