"use server";

import { serverApiClient } from "#root/lib/api/client";
import type { RemoteData } from "#root/lib/api/types";
import { wrapApiCall, getServerAuthHeaders } from "#root/lib/api/utils";

import type { APIPlatformConnection } from "./integrations-models";

export async function getIntegrations(client = serverApiClient) {
  const headers = await getServerAuthHeaders();
  return wrapApiCall(() =>
    client
      .get("api/integrations", {
        headers,
      })
      .json<RemoteData<APIPlatformConnection[]>>(),
  );
}
