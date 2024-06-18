import { cache } from "@solidjs/router";

import { IntegrationType } from "./integrations-models";

import { getIntegrations } from "./integrations-server-api";

export const INTEGRATION_WINDOW_NAME = "integrationWindow";
export function openIntegrationWindow(integrationType: IntegrationType) {
  const windowParams =
    "menubar=no,resizable=no,scrollbars=yes,status=no,width=600,height=800,popup=yes";

  const mbWindow = window.open(
    `/integration/${integrationType}`,
    INTEGRATION_WINDOW_NAME,
    windowParams,
  );

  if (!mbWindow) {
    throw new Error("Failed to open integration window");
  }

  return mbWindow;
}

export const getUserIntegrations = cache(() => {
  "use server";
  return getIntegrations();
}, "getUserIntegrations");
