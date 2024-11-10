import "#style/styles.css";

import { H } from "highlight.run";
import { RouterProvider } from "@tanstack/react-router";
import { StrictMode } from "react";
import { ErrorBoundary } from "@highlight-run/react";
import { createRoot } from "react-dom/client";

import { router } from "#root/router";

const rootElement = document.getElementById("root")!;

if (window.MusicKit) {
  console.debug("[Debug] MusicKit loaded");
}

H.init(import.meta.env.VITE_HIGHLIGHT_PROJECT_ID, {
  serviceName: "SwapifyWeb",
  version: "1.0.0",
  debug: import.meta.env.VITE_APP_VERSION,
  reportConsoleErrors: true,
  // manualStart: import.meta.env.DEV,
  tracingOrigins: true,
  networkRecording: {
    enabled: true,
    disableWebSocketEventRecordings: true,
    urlBlocklist: [],
  },
});

createRoot(rootElement).render(
  <ErrorBoundary>
    <StrictMode>
      <RouterProvider router={router} />
    </StrictMode>
  </ErrorBoundary>,
);
