import { useEffect } from "react";

import { useScreenOptions } from "#root/components/app-screen-layout";

import { usePlaylistSyncSocket } from "./hooks/use-playlist-sync-socket";

export function PlaylistsPage() {
  const { setPageTitle } = useScreenOptions();

  const { sendMessage } = usePlaylistSyncSocket();

  function syncAppleMusic() {
    sendMessage("sync", {
      playlistId: "library",
      platformName: "applemusic",
    });
  }

  function syncSpotify() {
    sendMessage("sync", {
      playlistId: "library",
      platformName: "spotify",
    });
  }

  useEffect(() => {
    setPageTitle("Playlists");
  }, []);

  return (
    <h1>
      Playlists
      <button onClick={syncAppleMusic}>Sync apple music lib</button>
      <button onClick={syncSpotify}>Sync spotify lib</button>
    </h1>
  );
}
