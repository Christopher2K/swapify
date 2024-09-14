import { css } from "#style/css";
import { Box, styled, HStack } from "#style/jsx";
import { PlatformLogo } from "#root/components/platform-logo";
import { PlaylistStatus } from "#root/components/playlist-status";
import { Button } from "#root/components/ui/button";
import { APIPlatformName, APIPlaylist } from "#root/services/api.types";
import { Card } from "#root/components/ui/card";
import { DefinitionList } from "#root/components/definition-list";
import { timeAgo } from "#root/services/time-ago";

type PlaylistsTableProps = {
  playlists?: APIPlaylist[];
  onSynchronizeItem: (platform: APIPlatformName) => void;
};

export function PlaylistsTable({
  playlists,
  onSynchronizeItem,
}: PlaylistsTableProps) {
  return (
    <Box
      display="grid"
      gridTemplateColumns={["1fr", undefined, undefined, "1fr 1fr 1fr"]}
      gap="4"
      width="full"
    >
      {playlists?.map((p) => (
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
              <PlaylistStatus syncStatus={p.syncStatus} />
            </Card.Description>
          </Card.Header>
          <Card.Body>
            <DefinitionList
              items={[
                {
                  title: "Last updated",
                  value: timeAgo.format(new Date(p.updatedAt)),
                },
                {
                  title: "Tracks synchronized",
                  value:
                    p.tracksTotal != undefined
                      ? `${p.tracksTotal} tracks`
                      : "Unknown",
                },
              ]}
            />
          </Card.Body>
          <Card.Footer gap="3" flexWrap="wrap">
            <Button
              flex="1"
              flexShrink="0"
              onClick={() => onSynchronizeItem(p.platformName)}
            >
              Synchronize
            </Button>
          </Card.Footer>
        </Card.Root>
      ))}
    </Box>
  );
}
