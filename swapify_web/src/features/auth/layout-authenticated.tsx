import { type PropsWithChildren } from "react";
import { Outlet, useNavigate } from "@tanstack/react-router";

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
