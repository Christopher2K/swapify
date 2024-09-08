import { useEffect } from "react";

import { useScreenOptions } from "#root/components/app-screen-layout";
import { VStack } from "#style/jsx";

import { PlaylistsTable } from "./components/playlists-table";
import { usePlaylistSyncSocket } from "./hooks/use-playlist-sync-socket";
import { useLibrariesQuery } from "./hooks/use-libraries-query";

export function PlaylistsPage() {
  const { setPageTitle } = useScreenOptions();
  const { sendMessage } = usePlaylistSyncSocket();
  const { libraries } = useLibrariesQuery();

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
    <VStack w="full" h="full" p="4">
      <PlaylistsTable playlists={libraries} />
    </VStack>
  );
}
