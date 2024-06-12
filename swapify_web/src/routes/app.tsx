import { RouteSectionProps } from "@solidjs/router";

import Layout from "./(static)";
import { protectedRouteCheck } from "#root/services/auth";

export default function AppLayout(props: RouteSectionProps) {
  protectedRouteCheck();

  return <Layout>{props.children}</Layout>;
}
