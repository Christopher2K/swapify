import { StrictMode } from "react";
import { ErrorBoundary } from "@highlight-run/react";
import { RouterProvider } from "@tanstack/react-router";

import { router } from "#root/router";

export const App = () => (
  <ErrorBoundary>
    <StrictMode>
      <RouterProvider router={router} />
    </StrictMode>
  </ErrorBoundary>
);
