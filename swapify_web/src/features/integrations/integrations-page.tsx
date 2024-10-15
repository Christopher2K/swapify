import { VStack, Box } from "#style/jsx";

import { PlatformLogo } from "#root/components/platform-logo";
import { Heading } from "#root/components/ui/heading";

import { IntegrationCard } from "./components/integration-card";
import { useAppleMusicConnect } from "./hooks/use-apple-music-connect";
import { useSpotifyConnect } from "./hooks/use-spotify-connect";

export function IntegrationsPage() {
  const {
    connect: connectToAppleMusic,
    isLoading: isAppleMusicLoading,
    isConnected: isAppleMusicConnected,
  } = useAppleMusicConnect();

  const {
    connect: connectToSpotify,
    isLoading: isSpotifyLoading,
    isConnected: isSpotifyConnected,
  } = useSpotifyConnect();

  return (
    <VStack
      w="full"
      h="full"
      p="4"
      gap="10"
      justifyContent="flex-start"
      alignItems="flex-start"
    >
      <VStack
        w="full"
        gap="4"
        justifyContent="flex-start"
        alignItems="flex-start"
      >
        <Heading as="h2" size="lg">
          Music platforms
        </Heading>
        <Box
          w="full"
          display="grid"
          gridTemplateColumns={["1fr", undefined, undefined, "1fr 1fr 1fr"]}
          gridAutoRows="1fr"
          gap="4"
        >
          <IntegrationCard
            onConnectClick={connectToAppleMusic}
            icon={<PlatformLogo platform="applemusic" />}
            title="Apple Music"
            description="Connect your Apple Music account to start transferring your music now!"
            isLoading={isAppleMusicLoading}
            isConnected={isAppleMusicConnected}
          />
          <IntegrationCard
            onConnectClick={connectToSpotify}
            icon={<PlatformLogo platform="spotify" />}
            title="Spotify"
            description="Connect your Spotify account to start transferring your music now!"
            isLoading={isSpotifyLoading}
            isConnected={isSpotifyConnected}
          />
        </Box>
      </VStack>
    </VStack>
  );
}
