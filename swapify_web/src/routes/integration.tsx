import { RouteSectionProps } from "@solidjs/router";

import { VStack } from "#style/jsx";
import { createProtectedRouteCheck } from "#root/lib/auth/auth-services";

export default function IntegrationLayout(props: RouteSectionProps) {
  createProtectedRouteCheck();

  return (
    <VStack h="100vh" justifyContent="center" alignItems="center">
      {props.children}
    </VStack>
  );
}
