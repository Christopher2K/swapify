import { useEffect } from "react";

import { tsr } from "#root/services/api";
import { useScreenOptions } from "#root/components/app-screen-layout";
import { Heading } from "#root/components/ui/heading";
import { VStack } from "#style/jsx";

import { PlaylistsTable } from "./components/playlists-table";
import { useLibrariesQuery } from "./hooks/use-libraries-query";
import { usePlaylistSyncSocket } from "./hooks/use-playlist-sync-socket";
import { useAuthenticatedUser } from "../auth/authentication-provider";

export function PlaylistsPage() {
  const { setPageTitle } = useScreenOptions();
  const { libraries } = useLibrariesQuery();
  const { id } = useAuthenticatedUser();
  // FIXME: this only exist for testing, the UX flow needs to be WAY better
  const { mutateAsync: syncLibrary } = tsr.startSyncLibraryJob.useMutation({});
  const { addEventListener } = usePlaylistSyncSocket(id);

  useEffect(() => setPageTitle("Playlists"), []);

  useEffect(
    () => addEventListener("status_update", console.log),
    [addEventListener],
  );

  return (
    <VStack w="full" h="full" p="4" gap="10">
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
