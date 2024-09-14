import { useChannel } from "#root/services/realtime";
import type {
  APIPlatformName,
  APIPlaylistSyncStatus,
} from "#root/services/api.types";
import type {
  APIJobUpdateNotification,
  APIJobErrorNotification,
} from "#root/services/realtime.types";

export type APISyncPlaylistError = APIJobErrorNotification<{
  playlistId: string;
  platformName: APIPlatformName;
}>;

export type APISyncPlaylistUpdate = APIJobUpdateNotification<{
  playlistId: string;
  platformName: APIPlatformName;
  tracksTotal: number;
  syncedTracksTotal: number;
  status: APIPlaylistSyncStatus;
}>;

export type PlaylistSyncSocketOutgoingMessageRecord = {};

export type PlaylistSyncSocketIncomingMessageRecord = {
  status_update: {
    payload: APISyncPlaylistUpdate | APISyncPlaylistError;
  };
};

export function usePlaylistSyncSocket(userId: string) {
  const channelName = "playlist_sync:" + userId;
  return useChannel<
    PlaylistSyncSocketIncomingMessageRecord,
    PlaylistSyncSocketOutgoingMessageRecord
  >(channelName);
}
