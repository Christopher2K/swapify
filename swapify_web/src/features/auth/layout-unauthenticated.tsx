import { type PropsWithChildren } from "react";
import { Outlet, useNavigate } from "@tanstack/react-router";

import { AuthenticationProvider } from "./authentication-provider";

export function UnauthenticatedLayout({ children }: PropsWithChildren) {
  const navigate = useNavigate();

  return (
    <AuthenticationProvider
      renderIfUnauthenticated={() => <>{children}</>}
      renderIfAuthenticated={() => {
        navigate({ to: "/", replace: true });
        return null;
      }}
    />
  );
}
