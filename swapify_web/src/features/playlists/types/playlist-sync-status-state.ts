import { APIPlaylistSyncStatus } from "#root/services/api.types";

export type PlaylistStatusState = {
  status: APIPlaylistSyncStatus;
  total: number;
  totalSynced: number;
};
