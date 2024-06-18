import { RouteSectionProps } from "@solidjs/router";

import Layout from "./(static)";
import { createProtectedRouteCheck } from "#root/lib/auth/auth-services";

export default function AppLayout(props: RouteSectionProps) {
  createProtectedRouteCheck();

  return <Layout>{props.children}</Layout>;
}
