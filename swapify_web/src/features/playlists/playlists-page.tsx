import { useEffect, useState } from "react";

import { tsr } from "#root/services/api";
import { Heading } from "#root/components/ui/heading";
import { VStack } from "#style/jsx";
import { useJobUpdateContext } from "#root/features/job/components/job-update-context";
import type {
  APISyncPlaylistError,
  APISyncPlaylistUpdate,
} from "#root/features/job/hooks/use-job-update-socket";

import { PlaylistsTable } from "./components/playlists-table";
import { useLibrariesQuery } from "./hooks/use-libraries-query";
import type { PlaylistStatusState } from "./types/playlist-sync-status-state";
import { APIPlatformName } from "#root/services/api.types";
import { onJobUpdate } from "../job/utils/on-job-update";

export function PlaylistsPage() {
  const { libraries, refetch: refetchLibraries } = useLibrariesQuery();
  const { mutateAsync: syncLibrary } = tsr.startSyncLibraryJob.useMutation({});
  const { addJobUpdateEventListener } = useJobUpdateContext();
  const [playlistStatuses, setPlaylistStatuses] = useState<
    Record<
      APIPlatformName,
      { [playlistId: string]: PlaylistStatusState | undefined }
    >
  >({
    spotify: {},
    applemusic: {},
  });

  function onSynchronizeRequest(
    platformName: APIPlatformName,
    playlistId: string,
  ) {
    syncLibrary({ params: { platformName } });
    setPlaylistStatuses((state) => {
      return {
        ...state,
        [platformName]: {
          ...state[platformName],
          [playlistId]: {
            totalSynced: 0,
            status: "syncing",
          },
        },
      };
    });
  }

  function onSyncLibraryError(msg: APISyncPlaylistError) {
    setPlaylistStatuses((state) => {
      return {
        ...state,
        [msg.data.platformName]: {
          ...state[msg.data.platformName],
          [msg.data.playlistId]: {
            totalSynced: 0,
            status: "error",
          },
        },
      };
    });
  }

  function onSyncLibraryUpdate(msg: APISyncPlaylistUpdate) {
    setPlaylistStatuses((state) => {
      if (msg.data.status === "synced") {
        refetchLibraries();
      }

      return {
        ...state,
        [msg.data.platformName]: {
          ...state[msg.data.platformName],
          [msg.data.playlistId]: {
            status: msg.data.status,
            total: msg.data.tracksTotal,
            totalSynced: msg.data.syncedTracksTotal,
          },
        },
      };
    });
  }

  useEffect(
    () =>
      addJobUpdateEventListener(
        "job_update",
        onJobUpdate("sync_library", onSyncLibraryUpdate, onSyncLibraryError),
      ),

    [],
  );

  return (
    <VStack w="full" h="full" p="4" gap="10">
      <VStack
        w="full"
        gap="4"
        justifyContent="flex-start"
        alignItems="flex-start"
      >
        <Heading as="h2" size="lg">
          Your music libraries
        </Heading>
        <PlaylistsTable
          playlists={libraries}
          playlistStatuses={playlistStatuses}
          onSynchronizeItem={onSynchronizeRequest}
        />
      </VStack>

      <VStack
        w="full"
        gap="4"
        justifyContent="flex-start"
        alignItems="flex-start"
      >
        <Heading as="h2" size="lg">
          Your library playlists
        </Heading>
        <p>Coming soon...</p>
      </VStack>
    </VStack>
  );
}
