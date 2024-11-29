import { lazy, Suspense, useEffect, type PropsWithChildren } from "react";
import {
  Outlet,
  createRoute,
  createRouter,
  createRootRouteWithContext,
  useMatches,
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
import { Navbar } from "./features/marketing/components/page-container";

const TanStackRouterDevtools = import.meta.env.DEV
  ? lazy(() =>
      import("@tanstack/router-devtools").then((res) => ({
        default: res.TanStackRouterDevtools,
      })),
    )
  : () => null;

function Meta({ children }: PropsWithChildren) {
  const matches = useMatches();
  const meta = matches.at(-1)?.meta?.find((meta) => meta?.title);

  useEffect(() => {
    document.title = ["Swapify", meta?.title].filter(Boolean).join(" | ");
  }, [meta]);

  return children;
}

const rootRoute = createRootRouteWithContext()({
  component: () => (
    <Root>
      <Meta>
        <Outlet />
        <Suspense>
          <TanStackRouterDevtools />
        </Suspense>
      </Meta>
    </Root>
  ),
  head: () => {
    return {
      meta: [{ title: "Swapify" }],
    };
  },
});

const prefixRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/app",
  component: () => <Outlet />,
});

const appScreenLayoutRoute = createRoute({
  getParentRoute: () => prefixRoute,
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
  getParentRoute: () => prefixRoute,
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
  getParentRoute: () => prefixRoute,
  id: "unauthenticated",
  component: () => (
    <UnauthenticatedLayout>
      <Navbar />
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
  head: () => {
    return {
      meta: [{ title: "Sign in" }],
    };
  },
});

const signupRoute = createRoute({
  getParentRoute: () => unauthenticatedLayoutRoute,
  path: "/sign-up",
  component: PageSignup,
  head: () => {
    return {
      meta: [{ title: "Sign up" }],
    };
  },
});

const passwordResetRequestRoute = createRoute({
  getParentRoute: () => unauthenticatedLayoutRoute,
  path: "/password-reset",
  component: PasswordResetRequestPage,
  head: () => {
    return {
      meta: [{ title: "Password reset" }],
    };
  },
});

const passwordResetConfirmRoute = createRoute({
  getParentRoute: () => unauthenticatedLayoutRoute,
  path: "/password-reset/$code",
  component: PasswordResetConfirmPage,
  head: () => {
    return {
      meta: [{ title: "Password reset" }],
    };
  },
});

const indexRoute = createRoute({
  getParentRoute: () => appScreenLayoutRoute,
  path: "/",
  component: DashboardPage,
  head: () => {
    return {
      meta: [{ title: "Dashboard" }],
    };
  },
});

const integrationsRoute = createRoute({
  getParentRoute: () => appScreenLayoutRoute,
  path: "/integrations",
  component: IntegrationsPage,
  head: () => {
    return {
      meta: [{ title: "Integrations" }],
    };
  },
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
  head: () => {
    return {
      meta: [{ title: "Integrations" }],
    };
  },
});

const playlistsRoute = createRoute({
  getParentRoute: () => appScreenLayoutRoute,
  path: "/playlists",
  component: PlaylistsPage,
  head: () => {
    return {
      meta: [{ title: "Playlists" }],
    };
  },
});

const transfersRoute = createRoute({
  getParentRoute: () => appScreenLayoutRoute,
  path: "/transfers",
  component: TransfersPage,
  head: () => {
    return {
      meta: [{ title: "Transfers" }],
    };
  },
});

const routeTree = rootRoute.addChildren([
  prefixRoute.addChildren([
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
