import { useChannel } from "#root/services/realtime";

type OutgoingMessageRecord = {
  sync: {
    payload: {
      playlistId: string;
      platformName: string;
    };
    response: {};
  };
  status: {
    payload: {
      playlistId: string;
      platformName: string;
    };
    response: {};
  };
};

type IncomingMessageRecord = {
  sync_status: {
    payload: {};
  };
};

export function usePlaylistSyncSocket() {
  const channelName = "playlist_sync";
  return useChannel<IncomingMessageRecord, OutgoingMessageRecord>(channelName);
}
