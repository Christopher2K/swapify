import { H } from "highlight.run";
import {
  type PropsWithChildren,
  createContext,
  useContext,
  useEffect,
} from "react";

import { LoadingContainer } from "#root/components/loading-container";
import { useUserQuery } from "#root/features/auth/hooks/use-user-query";
import { type APIUser } from "#root/services/api.types";

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

  useEffect(() => {
    if (user) {
      H.identify(user.id, {
        email: user.email,
        username: user.username,
      });
    }
  }, [user]);

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

  return <LoadingContainer />;
}
