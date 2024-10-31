import { useMemo, useRef, useState } from "react";

import { useIntegrationsQuery } from "./use-integrations-query";

export function useAppleMusicConnect() {
  const { integrations, refetch: refetchIntegrations } = useIntegrationsQuery();
  const [isLoading, setIsLoading] = useState(false);
  const popupRef = useRef<Window | null>(null);

  const integration = useMemo(
    () =>
      integrations?.find((integration) => integration.name === "applemusic"),
    [integrations],
  );

  function connect() {
    const handleMessage = (event: MessageEvent) => {
      if (event.data?.integration !== "applemusic") return;
      switch (event.data.eventType) {
        case "success":
          console.debug("Apple Music success");

          break;
        case "error":
          console.debug("Apple Music error");
          break;
      }
      window.removeEventListener("message", handleMessage);
      onProcessEnd();
    };

    const popup = window.open(
      "/integrations/applemusic",
      "_blank",
      "popup=yes",
    )!;

    popupRef.current = popup;
    setIsLoading(true);

    window.addEventListener("message", handleMessage);

    const windowCheckInterval = setInterval(() => {
      if (popupRef.current?.closed) {
        clearInterval(windowCheckInterval);
        window.removeEventListener("message", handleMessage);
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
