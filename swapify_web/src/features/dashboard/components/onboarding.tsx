import { ReactNode, PropsWithChildren, useEffect } from "react";
import { FolderSync, Music2Icon, RefreshCcw } from "lucide-react";

import { HStack, Stack, VStack } from "#style/jsx";
import { css } from "#style/css";
import { Heading } from "#root/components/ui/heading";
import { Text } from "#root/components/ui/text";
import { Badge } from "#root/components/ui/badge";
import { useAppleMusicConnect } from "#root/features/integrations/hooks/use-apple-music-connect";
import { useSpotifyConnect } from "#root/features/integrations/hooks/use-spotify-connect";
import { useLibrariesQuery } from "#root/features/playlists/hooks/use-libraries-query";
import { PlatformLogo } from "#root/components/platform-logo";
import { tsr } from "#root/services/api";
import { APIPlatformName } from "#root/services/api.types";
import { useJobUpdateContext } from "#root/features/job/components/job-update-context";

import { PlatformButton } from "./platform-button";

export function Onboarding() {
  const { addJobUpdateEventListener } = useJobUpdateContext();
  const { refetch: refetchLibraries } = useLibrariesQuery();

  useEffect(
    () =>
      addJobUpdateEventListener("job_update", (payload) => {
        if (payload.tag === "JobUpdateNotification") {
          switch (payload.name) {
            // When platform sync is done, refetch the libraries
            case "sync_platform":
              return refetchLibraries();
            case "sync_library":
              if (payload.data.status === "synced") {
                return refetchLibraries();
              }
              return;
            default:
              return;
          }
        } else {
          // Handle error here
          return;
        }
      }),
    [],
  );

  return (
    <VStack
      width="full"
      justifyContent="flex-start"
      alignItems="flex-start"
      gap="4"
    >
      <IntegrationStep />
      <SynchronizationStep />
      <TransferStep />
    </VStack>
  );
}

export type StepProps = PropsWithChildren<{
  title: string;
  subtitle: string;
  icon: ReactNode;
  status?: "done" | "in_progress";
}>;
const Step = ({ children, title, icon, subtitle, status }: StepProps) => {
  return (
    <VStack
      w="100%"
      gap="4"
      justifyContent="flex-start"
      alignItems="flex-start"
    >
      <HStack justifyContent="flex-start" alignItems="center">
        <Heading as="h2" textStyle="lg">
          {title}
        </Heading>
        {status && (
          <Badge
            variant="solid"
            backgroundColor={status === "done" ? "green" : "blue.10"}
          >
            {status === "done" ? "Completed" : "In progress"}
          </Badge>
        )}
      </HStack>

      <HStack
        w="full"
        gap="4"
        justifyContent="flex-start"
        alignItems={status === "done" ? "center" : "flex-start"}
      >
        <Stack
          width="12"
          height="12"
          backgroundColor="gray.12"
          borderRadius="md"
          justifyContent="center"
          alignItems="center"
          flexShrink={0}
          className={css({
            "& > svg": {
              stroke: "gray.1",
            },
          })}
        >
          {icon}
        </Stack>
        <VStack
          width="full"
          justifyContent="flex-start"
          alignItems="flex-start"
        >
          <Text fontSize="md" fontWeight="medium">
            {subtitle}
          </Text>
          {status === "done" ? null : children}
        </VStack>
      </HStack>
    </VStack>
  );
};

const IntegrationStep = () => {
  const {
    connect: appleMusicConnect,
    isConnected: isAppleMusicConnected,
    isLoading: isAppleMusicLoading,
  } = useAppleMusicConnect();

  const {
    connect: spotifyConnect,
    isConnected: isSpotifyConnected,
    isLoading: isSpotifyLoading,
  } = useSpotifyConnect();

  const isDone = isAppleMusicConnected && isSpotifyConnected;

  return (
    <Step
      title="Step 1"
      subtitle="Connect to your music platforms"
      icon={<Music2Icon />}
      status={isDone ? "done" : undefined}
    >
      <VStack
        justifyContent="flex-start"
        alignItems={isDone ? "center" : "flex-start"}
      >
        <Text color="gray.9">
          Swapify needs access to at least 2 music platforms before transfering
          your library and your playlists. It sounds scary but no worries, it's
          super simple. For now, we support Apple Music and Spotify.
        </Text>
        <HStack width="full" flexWrap="wrap" py="4">
          <PlatformButton
            icon={<PlatformLogo platform="applemusic" />}
            label={
              isAppleMusicConnected
                ? "Connected to Apple Music"
                : "Connect to Apple Music"
            }
            onClick={appleMusicConnect}
            isDone={isAppleMusicConnected}
            isLoading={isAppleMusicLoading}
          />

          <PlatformButton
            icon={<PlatformLogo platform="spotify" />}
            label={
              isSpotifyConnected ? "Connected to Spotify" : "Connect to Spotify"
            }
            onClick={spotifyConnect}
            isDone={isSpotifyConnected}
            isLoading={isSpotifyLoading}
          />
        </HStack>
      </VStack>
    </Step>
  );
};

// This is is considered as done when at least one playlist as been synchronized
const SynchronizationStep = () => {
  const { libraries, refetch: refetchLibraries } = useLibrariesQuery();
  const { mutateAsync: syncLibrary } = tsr.startSyncLibraryJob.useMutation({});

  const isDone = libraries?.some((lib) => lib.syncStatus === "synced");
  const isLoading = libraries?.some((lib) => lib.syncStatus === "syncing");

  async function handleSyncLibrary(platformName: APIPlatformName) {
    try {
      await syncLibrary({ params: { platformName } });
      await refetchLibraries();
      // TODO: toast success
    } catch (e) {
      // TODO: error toast
    }
  }

  return (
    <Step
      title="Step 2"
      subtitle="Synchronize your libraries"
      icon={<RefreshCcw />}
      status={isDone ? "done" : isLoading ? "in_progress" : undefined}
    >
      <VStack justifyContent="flex-start" alignItems="flex-start">
        <Text color="gray.9">
          Now that we have access to your platforms, synchronize the library
          you'd like to transfer to other platforms. This will allow our system
          to know about the tracks
        </Text>

        <HStack width="full" flexWrap="wrap">
          {libraries?.map((lib) => (
            <PlatformButton
              key={lib.id}
              icon={<PlatformLogo platform={lib.platformName} />}
              label={`Synchronize your ${lib.platformName}`}
              isDone={lib.syncStatus === "synced"}
              isLoading={lib.syncStatus === "syncing"}
              onClick={() => handleSyncLibrary(lib.platformName)}
            />
          ))}
        </HStack>
      </VStack>
    </Step>
  );
};

const TransferStep = () => {
  return (
    <Step title="Step 3" subtitle="Start a transfer" icon={<FolderSync />}>
      Transfer step
    </Step>
  );
};
