import { useNavigate } from "@tanstack/react-router";
import { type PropsWithChildren } from "react";

import { AuthenticationProvider } from "./authentication-provider";

export function AuthenticatedLayout({ children }: PropsWithChildren) {
  const navigate = useNavigate();

  return (
    <AuthenticationProvider
      renderIfAuthenticated={() => <>{children}</>}
      renderIfUnauthenticated={() => {
        navigate({ to: "/sign-in", replace: true });
        return null;
      }}
    />
  );
}
