import { APIPlaylistSyncStatus } from "#root/services/api.types";
import { humanReadableSyncStatus } from "#root/features/playlists/utils/playlist-utils";

import { cva } from "#style/css";
import { styled } from "#style/jsx";

export const playlistStatusBadgeStyle = cva({
  base: {
    fontWeight: "medium",
    fontSize: "sm",
    py: "1",
    px: "2",
    borderRadius: "sm",
  },
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
    <styled.span className={playlistStatusBadgeStyle({ syncStatus })}>
      {humanReadableSyncStatus[syncStatus]}
    </styled.span>
  );
}
