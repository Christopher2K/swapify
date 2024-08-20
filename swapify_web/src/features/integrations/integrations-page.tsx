import { useEffect, useState, useRef, useMemo } from "react";

import { useScreenOptions } from "#root/components/app-screen-layout";

import { VStack, Box } from "#style/jsx";

import AppleMusicIcon from "#root/components/icons/apple-music.svg?react";
import SpotifyIcon from "#root/components/icons/spotify.svg?react";
import { tsr } from "#root/services/api";

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
    setPageTitle("Integrations");

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
    <VStack w="full" h="full" p="4">
      <Box
        bg="accent.1"
        w="full"
        minH="full"
        boxShadow="sm"
        borderRadius="md"
        p="4"
        overflow="scroll"
      >
        <Box
          w="full"
          display="grid"
          gridTemplateColumns={["1fr", undefined, undefined, "1fr 1fr 1fr"]}
          gridAutoRows="1fr"
          gap="4"
        >
          <IntegrationCard
            onConnectClick={connectAppleMusic}
            icon={<AppleMusicIcon />}
            title="Apple Music"
            description="Connect your Apple Music account to start transferring your music now!"
            isLoading={appleMusicButtonLoadingState}
            isConnected={isAppleMusicConnected}
          />
          <IntegrationCard
            onConnectClick={connectSpotify}
            icon={<SpotifyIcon />}
            title="Spotify"
            description="Connect your Spotify account to start transferring your music now!"
            isLoading={spotifyButtonLoadingState}
            isConnected={isSpotifyConnected}
          />
        </Box>
      </Box>
    </VStack>
  );
}
