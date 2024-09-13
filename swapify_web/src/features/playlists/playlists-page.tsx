import { useEffect } from "react";

import { useScreenOptions } from "#root/components/app-screen-layout";
import { Heading } from "#root/components/ui/heading";
import { Button } from "#root/components/ui/button";
import { HStack, VStack } from "#style/jsx";

import { PlaylistsTable } from "./components/playlists-table";
import { useLibrariesQuery } from "./hooks/use-libraries-query";
import { tsr } from "#root/services/api";

export function PlaylistsPage() {
  const { setPageTitle } = useScreenOptions();
  const { libraries } = useLibrariesQuery();
  // FIXME: this only exist for testing, the UX flow needs to be WAY better
  const { mutateAsync: syncPlatform } = tsr.startSyncPlatformJob.useMutation(
    {},
  );
  const { mutateAsync: syncLibrary } = tsr.startSyncLibraryJob.useMutation({});

  useEffect(() => {
    setPageTitle("Playlists");
  }, []);

  return (
    <VStack w="full" h="full" p="4" gap="10">
      <HStack w="full" justifyContent="flex-start">
        <Button
          onClick={() =>
            syncPlatform({ params: { platformName: "applemusic" } })
          }
        >
          Synchronize Apple Music Library
        </Button>
        <Button
          onClick={() => syncPlatform({ params: { platformName: "spotify" } })}
        >
          Synchronize Spotify Library
        </Button>
      </HStack>
      <VStack
        w="full"
        gap="4"
        justifyContent="flex-start"
        alignItems="flex-start"
      >
        <Heading as="h2" size="xl">
          Libraries
        </Heading>
        <PlaylistsTable
          playlists={libraries}
          onSynchronizeItem={(platformName) =>
            syncLibrary({ params: { platformName } })
          }
        />
      </VStack>

      <VStack
        w="full"
        gap="4"
        justifyContent="flex-start"
        alignItems="flex-start"
      >
        <Heading as="h2" size="xl">
          Playlists
        </Heading>
        <p>Coming soon...</p>
      </VStack>
    </VStack>
  );
}
