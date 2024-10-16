import { useEffect, useMemo, useRef, useState } from "react";

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
    const popup = window.open("/integrations/spotify", "_blank", "popup=yes")!;

    popupRef.current = popup;
    setIsLoading(true);

    const windowCheckInterval = setInterval(() => {
      if (popupRef.current?.closed) {
        clearInterval(windowCheckInterval);
        onProcessEnd();
      }
    }, 1000);
  }

  async function onProcessEnd() {
    await refetchIntegrations();
    setIsLoading(false);
  }

  useEffect(() => {
    function handleMessage(event: MessageEvent) {
      if (event.data?.integration !== "spotify") return;
      switch (event.data.eventType) {
        case "success":
          console.debug("Spotify success");

          break;
        case "error":
          console.debug("Spotify error");
          break;
      }
      onProcessEnd();
    }

    window.addEventListener("message", handleMessage);
    return () => window.removeEventListener("message", handleMessage);
  }, [onProcessEnd]);

  return {
    connect,
    isLoading,
    isConnected: Boolean(integration),
  };
}
