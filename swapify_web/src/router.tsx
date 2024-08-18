import {
  Outlet,
  createRouter,
  createRoute,
  createRootRoute,
} from "@tanstack/react-router";
import { TanStackRouterDevtools } from "@tanstack/router-devtools";
import { z } from "zod";

import { Root } from "#root/root";
import { Container } from "#root/components/container";
import { PageSignin } from "#root/features/auth/page-signin";
import { PageSignup } from "#root/features/auth/page-signup";
import { DashboardPage } from "#root/features/dashboard/dashboard-page";
import { IntegrationsPage } from "#root/features/integrations/integrations-page";
import { AuthenticatedLayout } from "#root/features/auth/layout-authenticated";
import { UnauthenticatedLayout } from "#root/features/auth/layout-unauthenticated";
import { AppScreenLayout } from "#root/components/app-screen-layout";
import { IntegrationConfigurationPage } from "#root/features/integrations/integration-configuration-page";

const rootRoute = createRootRoute({
  component: () => (
    <Root>
      <Outlet />
      <TanStackRouterDevtools />
    </Root>
  ),
});

const appScreenLayoutRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: "app-screen-layout",
  component: () => (
    <AuthenticatedLayout>
      <AppScreenLayout>
        <Outlet />
      </AppScreenLayout>
    </AuthenticatedLayout>
  ),
});

const authenticatedLayoutRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: "authenticated",
  component: () => (
    <AuthenticatedLayout>
      <Container>
        <Outlet />
      </Container>
    </AuthenticatedLayout>
  ),
});

const unauthenticatedLayoutRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: "unauthenticated",
  component: () => (
    <UnauthenticatedLayout>
      <Container>
        <Outlet />
      </Container>
    </UnauthenticatedLayout>
  ),
});

const signInRouteSearch = z.object({
  justSignedUp: z.boolean().optional(),
});

const signinRoute = createRoute({
  getParentRoute: () => unauthenticatedLayoutRoute,
  path: "/sign-in",
  component: PageSignin,
  validateSearch: signInRouteSearch,
});

const signupRoute = createRoute({
  getParentRoute: () => unauthenticatedLayoutRoute,
  path: "/sign-up",
  component: PageSignup,
});

const indexRoute = createRoute({
  getParentRoute: () => appScreenLayoutRoute,
  path: "/",
  component: DashboardPage,
});

const integrationsRoute = createRoute({
  getParentRoute: () => appScreenLayoutRoute,
  path: "/integrations",
  component: IntegrationsPage,
});

const integrationConfigurationRoute = createRoute({
  getParentRoute: () => authenticatedLayoutRoute,
  path: "/integrations/$integrationName",
  component: IntegrationConfigurationPage,
});

const routeTree = rootRoute.addChildren([
  unauthenticatedLayoutRoute.addChildren([signinRoute, signupRoute]),
  authenticatedLayoutRoute.addChildren([integrationConfigurationRoute]),
  appScreenLayoutRoute.addChildren([indexRoute, integrationsRoute]),
]);
export const router = createRouter({
  routeTree,
});

declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}
