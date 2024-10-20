import "#style/styles.css";

import { RouterProvider } from "@tanstack/react-router";
import { StrictMode } from "react";
import { createRoot } from "react-dom/client";

import { router } from "#root/router";

const rootElement = document.getElementById("root")!;

if (window.MusicKit) {
  console.debug("[Debug] MusicKit loaded");
}

createRoot(rootElement).render(
  <StrictMode>
    <RouterProvider router={router} />
  </StrictMode>,
);
