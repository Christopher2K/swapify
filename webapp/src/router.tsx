import {
  Outlet,
  createRouter,
  createRoute,
  createRootRoute,
} from "@tanstack/react-router";
import { TanStackRouterDevtools } from "@tanstack/router-devtools";

import { Root } from "#root/root";
import { PageSignin } from "#root/features/auth/page-signin";
import { PageSignup } from "#root/features/auth/page-signup";
import { AuthenticatedLayout } from "#root/features/auth/layout-authenticated";

const rootRoute = createRootRoute({
  component: () => (
    <Root>
      <Outlet />
      <TanStackRouterDevtools />
    </Root>
  ),
});

const signinRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/signin",
  component: PageSignin,
});

const signupRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/signup",
  component: PageSignup,
});

const authenticatedLayoutRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: "authticated",
  component: AuthenticatedLayout,
});

const indexRoute = createRoute({
  getParentRoute: () => authenticatedLayoutRoute,
  path: "/",
  component: () => <h1>Hello World</h1>,
});

const routeTree = rootRoute.addChildren([
  signinRoute,
  signupRoute,
  authenticatedLayoutRoute.addChildren([indexRoute]),
]);
export const router = createRouter({
  routeTree,
});

declare module "@tanstack/react-router" {
  interface Register {
    router: typeof router;
  }
}
