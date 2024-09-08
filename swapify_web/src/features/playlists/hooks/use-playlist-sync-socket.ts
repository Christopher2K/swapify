import { useChannel } from "#root/services/realtime";

type OutgoingMessageRecord = {
  sync: {
    payload: {
      playlistId: string;
      platformName: "applemusic" | "spotify";
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
  status_update: {
    payload: {};
  };
};

export function usePlaylistSyncSocket() {
  const channelName = "playlist_sync";
  return useChannel<IncomingMessageRecord, OutgoingMessageRecord>(channelName);
}
