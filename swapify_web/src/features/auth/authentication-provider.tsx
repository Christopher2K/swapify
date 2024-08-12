import { type PropsWithChildren, createContext, useContext } from "react";

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

export type AuthenticationProviderProps = {
  renderIfAuthenticated: (user: APIUser) => React.ReactNode;
  renderIfUnauthenticated: () => React.ReactNode;
};

export function AuthenticationProvider({
  renderIfAuthenticated,
  renderIfUnauthenticated,
}: AuthenticationProviderProps) {
  const { user, isError } = useUserQuery();

  if (isError) {
    return renderIfUnauthenticated();
  }

  if (user != null) {
    return (
      <AuthenticatedUserProvider user={user}>
        {renderIfAuthenticated(user)}
      </AuthenticatedUserProvider>
    );
  }

  return <h1>Loading...</h1>;
}
