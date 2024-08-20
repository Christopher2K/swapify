import { useEffect } from "react";

import { useScreenOptions } from "#root/components/app-screen-layout";

export function PlaylistsPage() {
  const { setPageTitle } = useScreenOptions();

  useEffect(() => {
    setPageTitle("Playlists");
  }, []);

  return <h1>Playlists</h1>;
}
