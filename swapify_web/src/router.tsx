import { lazy, Suspense } from "react";
import {
  Outlet,
  createRootRoute,
  createRoute,
  createRouter,
} from "@tanstack/react-router";
import { z } from "zod";

import { AppScreenLayout } from "#root/components/app-screen-layout";
import { Container } from "#root/components/container";
import { AuthenticatedLayout } from "#root/features/auth/layout-authenticated";
import { UnauthenticatedLayout } from "#root/features/auth/layout-unauthenticated";
import { PageSignin } from "#root/features/auth/page-signin";
import { PageSignup } from "#root/features/auth/page-signup";
import { DashboardPage } from "#root/features/dashboard/dashboard-page";
import { IntegrationConfigurationPage } from "#root/features/integrations/integration-configuration-page";
import { IntegrationsPage } from "#root/features/integrations/integrations-page";
import { MetaProvider } from "#root/features/meta/components/meta-provider";
import { PlaylistsPage } from "#root/features/playlists/playlists-page";
import { TransfersPage } from "#root/features/transfers/transfers-page";
import { PasswordResetConfirmPage } from "#root/features/auth/password-reset-confirm-page";
import { PasswordResetRequestPage } from "#root/features/auth/password-reset-request-page";
import { Root } from "#root/root";

const TanStackRouterDevtools = import.meta.env.DEV
  ? lazy(() =>
      import("@tanstack/router-devtools").then((res) => ({
        default: res.TanStackRouterDevtools,
      })),
    )
  : () => null;

const rootRoute = createRootRoute({
  component: () => (
    <Root>
      <Outlet />
      <Suspense>
        <TanStackRouterDevtools />
      </Suspense>
    </Root>
  ),
});

const appScreenLayoutRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: "app-screen-layout",
  component: () => (
    <AuthenticatedLayout>
      <MetaProvider>
        <AppScreenLayout>
          <Outlet />
        </AppScreenLayout>
      </MetaProvider>
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
  from: z.enum(["sign-up", "password-reset"]).optional(),
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

const passwordResetRequestRoute = createRoute({
  getParentRoute: () => unauthenticatedLayoutRoute,
  path: "/password-reset",
  component: PasswordResetRequestPage,
});

const passwordResetConfirmRoute = createRoute({
  getParentRoute: () => unauthenticatedLayoutRoute,
  path: "/password-reset/$code",
  component: PasswordResetConfirmPage,
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

const integrationConfigurationRouteSearch = z.object({
  result: z.enum(["success", "error"]).optional(),
  error: z.string().optional(),
});
const integrationConfigurationRoute = createRoute({
  getParentRoute: () => authenticatedLayoutRoute,
  path: "/integrations/$integrationName",
  component: IntegrationConfigurationPage,
  validateSearch: integrationConfigurationRouteSearch,
});

const playlistsRoute = createRoute({
  getParentRoute: () => appScreenLayoutRoute,
  path: "/playlists",
  component: PlaylistsPage,
});

const transfersRoute = createRoute({
  getParentRoute: () => appScreenLayoutRoute,
  path: "/transfers",
  component: TransfersPage,
});

const routeTree = rootRoute.addChildren([
  unauthenticatedLayoutRoute.addChildren([
    signinRoute,
    signupRoute,
    passwordResetRequestRoute,
    passwordResetConfirmRoute,
  ]),
  authenticatedLayoutRoute.addChildren([integrationConfigurationRoute]),
  appScreenLayoutRoute.addChildren([
    indexRoute,
    integrationsRoute,
    playlistsRoute,
    transfersRoute,
  ]),
]);

export const router = createRouter({
  routeTree,
});

declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}
