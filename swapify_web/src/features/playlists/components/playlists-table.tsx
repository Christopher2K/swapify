import { PlatformLogo } from "#root/components/platform-logo";
import { PlaylistStatus } from "#root/components/playlist-status";
import { Button } from "#root/components/ui/button";
import { Table } from "#root/components/ui/table";
import { APIPlaylist } from "#root/services/api.types";
import { timeAgo } from "#root/services/time-ago";

import { css } from "#style/css";

import { isLibrary, humanReadableSyncStatus } from "../utils/playlist-utils";

type PlaylistsTableProps = {
  playlists?: APIPlaylist[];
};

export function PlaylistsTable({ playlists }: PlaylistsTableProps) {
  return (
    <Table.Root size="sm">
      <Table.Head>
        <Table.Row>
          <Table.Header>Platform</Table.Header>
          <Table.Header>Name</Table.Header>
          <Table.Header>Tracks</Table.Header>
          <Table.Header>Status</Table.Header>
          <Table.Header>Last synced</Table.Header>
          <Table.Header>Actions</Table.Header>
        </Table.Row>
      </Table.Head>
      <Table.Body>
        {playlists?.map((p) => (
          <Table.Row key={p.id}>
            <Table.Cell
              textAlign="center"
              fontWeight="medium"
              className={css({
                "& svg": {
                  width: "24px",
                  height: "auto",
                },
              })}
            >
              <PlatformLogo platform={p.platformName} />
            </Table.Cell>
            <Table.Cell>
              {p.tracksTotal != undefined
                ? `${p.tracksTotal} tracks`
                : "Unknown"}
            </Table.Cell>
            <Table.Cell fontWeight="medium">
              {isLibrary(p) ? "Music Library" : p.name}
            </Table.Cell>
            <Table.Cell>
              <PlaylistStatus syncStatus={p.syncStatus} />
            </Table.Cell>
            <Table.Cell>{timeAgo.format(new Date(p.updatedAt))}</Table.Cell>
            <Table.Cell>
              <Button size="xs">Synchronize</Button>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table.Body>
    </Table.Root>
  );
}
