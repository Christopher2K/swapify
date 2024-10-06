import { useEffect, useState } from "react";

import { tsr } from "#root/services/api";
import { useScreenOptions } from "#root/components/app-screen-layout";
import { Heading } from "#root/components/ui/heading";
import { VStack } from "#style/jsx";

import { PlaylistsTable } from "./components/playlists-table";
import { useLibrariesQuery } from "./hooks/use-libraries-query";
import {
  usePlaylistSyncSocket,
  PlaylistSyncSocketIncomingMessageRecord,
} from "./hooks/use-playlist-sync-socket";
import type { PlaylistStatusState } from "./types/playlist-sync-status-state";
import { APIPlatformName } from "#root/services/api.types";

export function PlaylistsPage() {
  const { setPageTitle } = useScreenOptions();
  const { libraries } = useLibrariesQuery();
  const { mutateAsync: syncLibrary } = tsr.startSyncLibraryJob.useMutation({});
  const { addEventListener } = usePlaylistSyncSocket();
  const [playlistStatuses, setPlaylistStatuses] = useState<
    Record<
      APIPlatformName,
      { [playlistId: string]: PlaylistStatusState | undefined }
    >
  >({
    spotify: {},
    applemusic: {},
  });

  function updatePlaylistStatus(
    msg: PlaylistSyncSocketIncomingMessageRecord["status_update"]["payload"],
  ) {
    setPlaylistStatuses((state) => {
      if (msg.name !== "sync_library") return state;

      switch (msg.tag) {
        case "JobUpdateNotification":
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
        case "JobErrorNotification":
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
      }
    });
  }

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

  useEffect(() => setPageTitle("Playlists"), []);

  useEffect(
    () => addEventListener("status_update", updatePlaylistStatus),
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
