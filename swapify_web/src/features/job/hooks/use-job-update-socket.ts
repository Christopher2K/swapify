import { useAuthenticatedUser } from "#root/features/auth/authentication-provider";
import type {
  APIJobStatus,
  APIPlatformName,
  APIPlaylistSyncStatus,
} from "#root/services/api.types";
import { useChannel } from "#root/services/realtime";
import type {
  APIJobErrorNotification,
  APIJobUpdateNotification,
} from "#root/services/realtime.types";

export type APISyncPlaylistError = APIJobErrorNotification<
  "sync_library",
  {
    playlistId: string;
    platformName: APIPlatformName;
  }
>;

export type APISyncPlaylistUpdate = APIJobUpdateNotification<
  "sync_library",
  {
    playlistId: string;
    platformName: APIPlatformName;
    tracksTotal: number;
    syncedTracksTotal: number;
    status: APIPlaylistSyncStatus;
  }
>;

export type APISyncPlatformError = APIJobErrorNotification<
  "sync_platform",
  {
    platformName: APIPlatformName;
  }
>;

export type APISyncPlatformUpdate = APIJobUpdateNotification<
  "sync_platform",
  {
    platformName: APIPlatformName;
    status: APIJobStatus;
  }
>;

export type JobUpdateSocketOutgoingMessageRecord = {};

export type JobUpdateSocketIncomingMessageRecord = {
  job_update: {
    payload:
      | APISyncPlaylistUpdate
      | APISyncPlaylistError
      | APISyncPlatformUpdate
      | APISyncPlatformError;
  };
};

export function useJobUpdateSocket() {
  const user = useAuthenticatedUser();
  const channelName = "job_update:" + user.id;
  return useChannel<
    JobUpdateSocketIncomingMessageRecord,
    JobUpdateSocketOutgoingMessageRecord
  >(channelName);
}
