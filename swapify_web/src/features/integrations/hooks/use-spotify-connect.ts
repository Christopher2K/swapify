import { useMemo, useRef, useState } from "react";

import { toaster } from "#root/components/toast";

import { useIntegrationsQuery } from "./use-integrations-query";

export function useSpotifyConnect() {
  const { integrations, refetch: refetchIntegrations } = useIntegrationsQuery();
  const [isLoading, setIsLoading] = useState(false);
  const popupRef = useRef<Window | null>(null);

  const integration = useMemo(
    () => integrations?.find((integration) => integration.name === "spotify"),
    [integrations],
  );

  function connect() {
    const handleMessage = (event: MessageEvent) => {
      if (event.data?.integration !== "spotify") return;
      switch (event.data.eventType) {
        case "success":
          toaster.success({
            description: "Connected to Spotify.",
          });

          break;
        case "error":
          toaster.error({
            description: "Failed to connect to Spotify. Please try again.",
          });
          break;
      }
      window.removeEventListener("message", handleMessage);
      onProcessEnd();
    };

    const popup = window.open(
      "/app/integrations/spotify",
      "_blank",
      "popup=yes",
    )!;

    popupRef.current = popup;
    setIsLoading(true);

    window.addEventListener("message", handleMessage);

    const windowCheckInterval = setInterval(() => {
      if (popupRef.current?.closed) {
        window.removeEventListener("message", handleMessage);
        clearInterval(windowCheckInterval);
        onProcessEnd();
      }
    }, 1000);
  }

  async function onProcessEnd() {
    await refetchIntegrations();
    setIsLoading(false);
  }

  return {
    connect,
    isLoading,
    isConnected: Boolean(integration),
  };
}
