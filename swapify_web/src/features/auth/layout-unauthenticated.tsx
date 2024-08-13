import { Outlet, useNavigate } from "@tanstack/react-router";

import { AuthenticationProvider } from "./authentication-provider";

export function UnauthenticatedLayout() {
  const navigate = useNavigate();

  return (
    <AuthenticationProvider
      renderIfUnauthenticated={() => <Outlet />}
      renderIfAuthenticated={() => {
        navigate({ to: "/", replace: true });
        return null;
      }}
    />
  );
}
