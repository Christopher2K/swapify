import {
  APIPlatformName,
  APIPlaylistSyncStatus,
} from "#root/services/api.types";
import type {
  APIJobUpdateNotification,
  APIJobErrorNotification,
} from "#root/services/realtime.types";

export type APISyncLibraryError = APIJobErrorNotification<{
  playlistId: string;
  platformName: APIPlatformName;
}>;

export type APISyncLibraryUpdate = APIJobUpdateNotification<{
  playlistId: string;
  platformName: APIPlatformName;
  tracksTotal: number;
  syncedTracksTotal: number;
  status: APIPlaylistSyncStatus;
}>;
