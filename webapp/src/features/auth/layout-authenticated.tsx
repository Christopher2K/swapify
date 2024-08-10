import { type PropsWithChildren } from "react";

import { AuthenticationProvider } from "./authentication-provider";

export type AuthenticatedLayoutProps = PropsWithChildren;
export function AuthenticatedLayout({ children }: PropsWithChildren) {
  return <AuthenticationProvider>{children}</AuthenticationProvider>;
}
