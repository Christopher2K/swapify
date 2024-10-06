import { ChevronDownIcon } from "lucide-react";

import { styled, VStack } from "#style/jsx";
import { Card } from "#root/components/ui/card";
import { Text } from "#root/components/ui/text";
import { Accordion } from "#root/components/ui/accordion";
import { useAppleMusicConnect } from "#root/features/integrations/hooks/use-apple-music-connect";
import { useSpotifyConnect } from "#root/features/integrations/hooks/use-spotify-connect";

import { PlatformButton } from "./platform-button";
import {
  OnboardingStepSchema,
  OnboardingStepSchemaType,
  getTitle,
} from "./onboarding.types";
import { PlatformLogo } from "#root/components/platform-logo";

export function Onboarding() {
  return (
    <Card.Root maxW="lg" w="full" alignSelf="center">
      <Card.Body py="4" px="10">
        <Accordion.Root
          multiple
          defaultValue={Object.values(OnboardingStepSchema.enum)}
          border="none"
        >
          {Object.values(OnboardingStepSchema.enum).map((value, index) => (
            <Step key={value} index={index + 1} step={value} />
          ))}
        </Accordion.Root>
      </Card.Body>
    </Card.Root>
  );
}

type StepProps = {
  index: number;
  step: OnboardingStepSchemaType;
};
function Step({ index, step }: StepProps) {
  const trigger = (
    <Accordion.ItemTrigger fontSize="md">
      <styled.span>
        <styled.span display="inline-block" mr="2">
          {index}.
        </styled.span>
        {getTitle(step)}
      </styled.span>
      <Accordion.ItemIndicator>
        <ChevronDownIcon />
      </Accordion.ItemIndicator>
    </Accordion.ItemTrigger>
  );

  const getContent = () => {
    switch (step) {
      case "PLATFORM":
        return <PlatformStep />;
      case "SYNC_LIB":
        return <SynchronizeStep />;
      case "READY":
        return null;
    }
  };

  return (
    <Accordion.Item value={step}>
      {trigger}
      <Accordion.ItemContent>{getContent()}</Accordion.ItemContent>
    </Accordion.Item>
  );
}

const PlatformStep = () => {
  const {
    connect: appleMusicConnect,
    isConnected: isAppleMusisConnected,
    isLoading: isAppleMusicLoading,
  } = useAppleMusicConnect();

  const {
    connect: spotifyConnect,
    isConnected: isSpotifyConnected,
    isLoading: isSpotifyLoading,
  } = useSpotifyConnect();

  return (
    <VStack gap="5">
      <VStack w="full">
        <Text>
          Swapify needs access to at least 2 music platforms before transfering
          your library and your playlists.
        </Text>
        <Text>
          It sounds scary but no worries, it's super simple. For now, we support
          Apple Music and Spotify.
        </Text>
      </VStack>

      <VStack width="full">
        <PlatformButton
          icon={<PlatformLogo platform="applemusic" />}
          label="Connect to Apple Music"
          onClick={appleMusicConnect}
          isConnected={isAppleMusisConnected}
          isLoading={isAppleMusicLoading}
        />

        <PlatformButton
          icon={<PlatformLogo platform="spotify" />}
          label="Connect to Spotify"
          onClick={spotifyConnect}
          isConnected={isSpotifyConnected}
          isLoading={isSpotifyLoading}
        />
      </VStack>
    </VStack>
  );
};

const SynchronizeStep = () => {
  return <VStack></VStack>;
};
