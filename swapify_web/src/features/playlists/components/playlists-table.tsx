import { Link as RouterLink } from "@tanstack/react-router";

import { DefinitionList } from "#root/components/definition-list";
import { PlatformLogo } from "#root/components/platform-logo";
import { PlaylistStatus } from "#root/components/playlist-status";
import { Button } from "#root/components/ui/button";
import { Card } from "#root/components/ui/card";
import { Text } from "#root/components/ui/text";
import { APIPlatformName, APIPlaylist } from "#root/services/api.types";
import { timeAgo } from "#root/services/time-ago";
import { css } from "#style/css";
import { Box, HStack, styled } from "#style/jsx";

import type { PlaylistStatusState } from "../types/playlist-sync-status-state";

type PlaylistsTableProps = {
  playlists?: APIPlaylist[];
  onSynchronizeItem: (platform: APIPlatformName, id: string) => void;
  playlistStatuses: Record<
    APIPlatformName,
    {
      [playlistId: string]: PlaylistStatusState | undefined;
    }
  >;
};

export function PlaylistsTable({
  playlists,
  playlistStatuses,
  onSynchronizeItem,
}: PlaylistsTableProps) {
  if (playlists?.length === 0) {
    return (
      <Box>
        <Text>
          No playlist here yet. Try to connect a platform first{" "}
          <RouterLink to="/integrations">here!</RouterLink>
        </Text>
      </Box>
    );
  }

  return (
    <Box
      display="grid"
      gridTemplateColumns={["1fr", undefined, undefined, "1fr 1fr 1fr"]}
      gap="4"
      width="full"
    >
      {playlists?.map((p) => {
        const syncItem = playlistStatuses[p.platformName][p.id];

        const status = syncItem?.status ?? p.syncStatus;
        const lastUpdatedValue =
          status === "syncing"
            ? "Syncing..."
            : timeAgo.format(new Date(p.updatedAt));
        const tracksSynchronizedValue =
          status === "syncing"
            ? syncItem
              ? `${syncItem.totalSynced} / ${syncItem.total} tracks sync`
              : "Getting informations..."
            : p.tracksTotal != undefined && status !== "error"
              ? `${p.tracksTotal} tracks`
              : "Unknown";

        const shouldDisableSyncButton = status === "syncing";

        return (
          <Card.Root key={p.id}>
            <Card.Header gap="2">
              <Card.Title>
                <HStack
                  w="full"
                  justifyContent="flex-start"
                  alignItems="center"
                  flexWrap="wrap"
                >
                  <PlatformLogo
                    platform={p.platformName}
                    className={css({
                      width: "30px",
                      height: "auto",
                      flexShrink: "0",
                    })}
                  />
                  <styled.span>{p.name ?? "Library"}</styled.span>
                </HStack>
              </Card.Title>
              <Card.Description>
                <PlaylistStatus syncStatus={status} />
              </Card.Description>
            </Card.Header>
            <Card.Body>
              <DefinitionList
                items={[
                  {
                    title: "Last updated",
                    value: lastUpdatedValue,
                  },
                  {
                    title: "Tracks synchronized",
                    value: tracksSynchronizedValue,
                  },
                ]}
              />
            </Card.Body>
            <Card.Footer gap="3" flexWrap="wrap">
              <Button
                flex="1"
                flexShrink="0"
                disabled={shouldDisableSyncButton}
                onClick={() => onSynchronizeItem(p.platformName, p.id)}
              >
                Synchronize
              </Button>
            </Card.Footer>
          </Card.Root>
        );
      })}
    </Box>
  );
}
