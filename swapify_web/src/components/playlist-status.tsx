import { humanReadableSyncStatus } from "#root/features/playlists/utils/playlist-utils";
import type { APIPlaylistSyncStatus } from "#root/services/api.types";

import { cva } from "#style/css";

import { Badge } from "./ui/badge";

export const playlistStatusBadgeStyle = cva({
  base: {},
  variants: {
    syncStatus: {
      synced: {
        backgroundColor: "grass.8",
        color: "grass.1",
      },
      unsynced: {
        backgroundColor: "gray.8",
        color: "gray.1",
      },
      syncing: {
        backgroundColor: "blue.8",
        color: "blue.1",
      },
      error: {
        backgroundColor: "red.8",
        color: "red.1",
      },
    },
  },
});

export type PlaylistStatusProps = {
  syncStatus: APIPlaylistSyncStatus;
};

export function PlaylistStatus({ syncStatus }: PlaylistStatusProps) {
  return (
    <Badge className={playlistStatusBadgeStyle({ syncStatus })}>
      {humanReadableSyncStatus[syncStatus]}
    </Badge>
  );
}
