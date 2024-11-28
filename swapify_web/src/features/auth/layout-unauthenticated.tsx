import { useNavigate } from "@tanstack/react-router";
import { type PropsWithChildren } from "react";

import { AuthenticationProvider } from "./authentication-provider";

export function UnauthenticatedLayout({ children }: PropsWithChildren) {
  const navigate = useNavigate();

  return (
    <AuthenticationProvider
      renderIfUnauthenticated={() => <>{children}</>}
      renderIfAuthenticated={() => {
        navigate({ to: "/app", replace: true });
        return null;
      }}
    />
  );
}
