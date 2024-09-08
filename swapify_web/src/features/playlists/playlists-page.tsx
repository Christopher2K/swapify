import { useEffect } from "react";

import { useScreenOptions } from "#root/components/app-screen-layout";
import { Heading } from "#root/components/ui/heading";
import { VStack } from "#style/jsx";

import { PlaylistsTable } from "./components/playlists-table";
import { useLibrariesQuery } from "./hooks/use-libraries-query";

export function PlaylistsPage() {
  const { setPageTitle } = useScreenOptions();
  const { libraries } = useLibrariesQuery();

  useEffect(() => {
    setPageTitle("Playlists");
  }, []);

  return (
    <VStack w="full" h="full" p="4" gap="10">
      <VStack
        w="full"
        gap="4"
        justifyContent="flex-start"
        alignItems="flex-start"
      >
        <Heading as="h2" size="xl">
          Libraries
        </Heading>
        <PlaylistsTable playlists={libraries} />
      </VStack>

      <VStack
        w="full"
        gap="4"
        justifyContent="flex-start"
        alignItems="flex-start"
      >
        <Heading as="h2" size="xl">
          Playlists
        </Heading>
        <p>Coming soon...</p>
      </VStack>
    </VStack>
  );
}
