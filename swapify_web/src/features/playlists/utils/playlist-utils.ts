import type {
  APIPlaylist,
  APIPlaylistSyncStatus,
} from "#root/services/api.types";

export const humanReadableSyncStatus: Record<APIPlaylistSyncStatus, string> = {
  error: "Synchronization Error",
  unsynced: "Needs synchronization",
  synced: "Synchronized",
  syncing: "Sychronizing",
};

export function isLibrary(playlist: APIPlaylist) {
  return playlist.userId === playlist.platformId;
}
