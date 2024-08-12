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
import { UnauthenticatedLayout } from "#root/features/auth/layout-unauthenticated";

const rootRoute = createRootRoute({
  component: () => (
    <Root>
      <Outlet />
      <TanStackRouterDevtools />
    </Root>
  ),
});

type SignInRouteSearch = {
  ["just-signed-up"]?: boolean;
};
const signinRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/sign-in",
  component: PageSignin,
  validateSearch: (search): SignInRouteSearch => {
    return {
      ["just-signed-up"]: search.justSignedUp === "true",
    };
  },
});

const signupRoute = createRoute({
  getParentRoute: () => rootRoute,
  path: "/sign-up",
  component: PageSignup,
});

const authenticatedLayoutRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: "authticated",
  component: AuthenticatedLayout,
});

const unauthenticatedLayoutRoute = createRoute({
  getParentRoute: () => rootRoute,
  id: "unauthenticated",
  component: UnauthenticatedLayout,
});

const indexRoute = createRoute({
  getParentRoute: () => authenticatedLayoutRoute,
  path: "/",
  component: () => <h1>Hello World</h1>,
});

const routeTree = rootRoute.addChildren([
  unauthenticatedLayoutRoute.addChildren([signinRoute, signupRoute]),
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
