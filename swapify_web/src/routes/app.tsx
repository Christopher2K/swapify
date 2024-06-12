import { RouteSectionProps } from "@solidjs/router";

import Layout from "./(static)";
import { createProtectedRouteCheck } from "#root/services/auth";

export default function AppLayout(props: RouteSectionProps) {
  createProtectedRouteCheck();

  return <Layout>{props.children}</Layout>;
}
