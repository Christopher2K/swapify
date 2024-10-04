import { useEffect, useState, useRef, useMemo } from "react";

import { useScreenOptions } from "#root/components/app-screen-layout";

import { VStack, Box } from "#style/jsx";

import { PlatformLogo } from "#root/components/platform-logo";

import { IntegrationCard } from "./components/integration-card";
import { useIntegrationsQuery } from "./hooks/use-integrations-query";

export function IntegrationsPage() {
  const { setPageTitle } = useScreenOptions();
  const [appleMusicButtonLoadingState, setAppleMusicButtonLoadingState] =
    useState(false);
  const [spotifyButtonLoadingState, setSpotifyButtonLoadingState] =
    useState(false);
  const appleMusicPopupRef = useRef<Window | null>(null);
  const spotifyPopupRef = useRef<Window | null>(null);
  const { integrations, refetch: refetchIntegrations } = useIntegrationsQuery();

  const isAppleMusicConnected = useMemo(
    () =>
      Boolean(
        integrations?.some((integration) => integration.name === "applemusic"),
      ),
    [integrations],
  );

  const isSpotifyConnected = useMemo(
    () =>
      Boolean(
        integrations?.some((integration) => integration.name === "spotify"),
      ),
    [integrations],
  );

  function connectAppleMusic() {
    const amPopup = window.open(
      "/integrations/applemusic",
      "_blank",
      "popup=yes",
    )!;
    appleMusicPopupRef.current = amPopup;
    setAppleMusicButtonLoadingState(true);

    const windowCheckInterval = setInterval(() => {
      if (appleMusicPopupRef.current?.closed) {
        clearInterval(windowCheckInterval);
        setSpotifyButtonLoadingState(false);
      }
    }, 1000);
  }

  function connectSpotify() {
    const spotifyPopup = window.open(
      "/integrations/spotify",
      "_blank",
      "popup=yes",
    )!;
    spotifyPopupRef.current = spotifyPopup;
    setSpotifyButtonLoadingState(true);

    const windowCheckInterval = setInterval(() => {
      if (spotifyPopupRef.current?.closed) {
        clearInterval(windowCheckInterval);
        setSpotifyButtonLoadingState(false);
      }
    }, 1000);
  }

  useEffect(() => {
    setPageTitle("Music platforms");

    function handleMessage(event: MessageEvent) {
      if (event.data?.integration === "applemusic") {
        switch (event.data.eventType) {
          case "success":
            console.debug("Apple Music success");
            refetchIntegrations();

            break;
          case "error":
            console.debug("Apple Music error");
            break;
        }
        setAppleMusicButtonLoadingState(false);
      } else if (event.data?.integration === "spotify") {
        switch (event.data.eventType) {
          case "success":
            console.debug("Spotify success");
            refetchIntegrations();
            break;
          case "error":
            console.debug("Spotify error");
            break;
        }
        setSpotifyButtonLoadingState(false);
      }
    }

    window.addEventListener("message", handleMessage);

    return () => window.removeEventListener("message", handleMessage);
  }, []);

  return (
    <VStack w="full" h="full" p="4" gap="10">
      <Box
        w="full"
        display="grid"
        gridTemplateColumns={["1fr", undefined, undefined, "1fr 1fr 1fr"]}
        gridAutoRows="1fr"
        gap="4"
      >
        <IntegrationCard
          onConnectClick={connectAppleMusic}
          icon={<PlatformLogo platform="applemusic" />}
          title="Apple Music"
          description="Connect your Apple Music account to start transferring your music now!"
          isLoading={appleMusicButtonLoadingState}
          isConnected={isAppleMusicConnected}
        />
        <IntegrationCard
          onConnectClick={connectSpotify}
          icon={<PlatformLogo platform="spotify" />}
          title="Spotify"
          description="Connect your Spotify account to start transferring your music now!"
          isLoading={spotifyButtonLoadingState}
          isConnected={isSpotifyConnected}
        />
      </Box>
    </VStack>
  );
}
