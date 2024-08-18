import { useEffect } from "react";

import { useScreenOptions } from "#root/components/app-screen-layout";

import { VStack, Box } from "#style/jsx";

import AppleMusicIcon from "#root/components/icons/apple-music.svg?react";
import SpotifyIcon from "#root/components/icons/spotify.svg?react";

import { IntegrationCard } from "./components/integration-card";

export function IntegrationsPage() {
  const { setPageTitle } = useScreenOptions();

  function connectAppleMusic() {
    const _amPopup = window.open(
      "/integrations/applemusic",
      "_blank",
      "popup=yes",
    );
  }

  function connectSpotify() {
    const _spotifyPopup = window.open(
      "/integrations/spotify",
      "_blank",
      "popup=yes",
    );
  }

  useEffect(() => {
    setPageTitle("Integrations");
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
          />
          <IntegrationCard
            onConnectClick={connectSpotify}
            icon={<SpotifyIcon />}
            title="Spotify"
            description="Connect your Spotify account to start transferring your music now!"
          />
        </Box>
      </Box>
    </VStack>
  );
}
