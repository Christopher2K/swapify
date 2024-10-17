import { useEffect, useState } from "react";

import { Heading } from "#root/components/ui/heading";

import { PlatformLogo } from "#root/components/platform-logo";
import { Badge } from "#root/components/ui/badge";
import { Button } from "#root/components/ui/button";
import { Text } from "#root/components/ui/text";
import { getPlatformName } from "#root/features/integrations/utils/get-platform-name";
import { useJobUpdateContext } from "#root/features/job/components/job-update-context";
import { onJobUpdate } from "#root/features/job/utils/on-job-update";
import { APITransfer } from "#root/services/api.types";
import { formatDateTime } from "#root/utils/date";
import { css, cva } from "#style/css";
import { HStack, Stack } from "#style/jsx";
import { toaster } from "#root/components/toast";
import { ThemedAlert } from "#root/components/themed-alert";

import { useCancelTransferMutation } from "../hooks/use-cancel-transfer-mutation";
import { useConfirmTransferMutation } from "../hooks/use-confirm-transfer-mutation";
import type { TransferStatus } from "../transfers.types";
import { getTransferStatus } from "../transfers.utils";
import { TransferProgress } from "./transfer-progress";

const statusStyle = cva({
  base: {},
  variants: {
    theme: {
      matching: {
        backgroundColor: "amber.11",
        color: "amber.4",
      },
      "wait-for-confirmation": {
        backgroundColor: "blue.11",
        color: "blue.4",
      },
      transfering: {
        backgroundColor: "blue.11",
        color: "blue.4",
      },
      cancelled: {
        backgroundColor: "gray.11",
        color: "gray.4",
      },
      done: {
        backgroundColor: "grass.11",
        color: "grass.4",
      },
      error: {
        backgroundColor: "tomato.11",
        color: "tomato.4",
      },
    },
  },
});

const getTransferStatusText = (status: TransferStatus) => {
  switch (status) {
    case "matching":
      return "Matching";
    case "wait-for-confirmation":
      return "Waiting for confirmation";
    case "transfering":
      return "Transfering";
    case "cancelled":
      return "Cancelled";
    case "done":
      return "Done";
    case "error":
      return "Error";
  }
};

type TransferRowProps = {
  transfer: APITransfer;
  refetchTransfers?: () => Promise<unknown>;
};
export function TransferRow({ transfer, refetchTransfers }: TransferRowProps) {
  const { confirmTransferAsync, isPending: isConfirmTransferPending } =
    useConfirmTransferMutation();
  const { cancelTransferAsync, isPending: isCancelTransferPending } =
    useCancelTransferMutation();
  const { addJobUpdateEventListener } = useJobUpdateContext();
  const [searchJobOffset, setSearchJobOffset] = useState<number | undefined>(
    undefined,
  );
  const [transferJobOffset, setTransferJobOffset] = useState<
    number | undefined
  >(undefined);

  const status = getTransferStatus(transfer);
  const canCancel = status === "wait-for-confirmation";
  const canConfirm = status === "wait-for-confirmation";
  const statusText = getTransferStatusText(status);

  const handleConfirmTransfer = async () => {
    try {
      await confirmTransferAsync(transfer.id);
      setTransferJobOffset(0);
      toaster.create({
        title: "Transfer confirmed",
        description:
          "Tracks are now being transfered to your destination platform.",
      });
    } catch (_) {}
  };

  const handleCancelTransfer = async () => {
    try {
      await cancelTransferAsync(transfer.id);

      toaster.create({
        title: "Transfer cancelled",
        description:
          "This transfer has been cancelled. You can start a new transfer if needed.",
      });
    } catch (_) {}
  };

  useEffect(
    () =>
      addJobUpdateEventListener(
        "job_update",
        onJobUpdate("search_tracks", ({ data }) => {
          if (data.transferId !== transfer.id) return;
          setSearchJobOffset(data.currentIndex);

          if (data.status === "done" && refetchTransfers) {
            refetchTransfers().finally(() => setSearchJobOffset(undefined));
          }
        }),
      ),
    [],
  );

  useEffect(
    () =>
      addJobUpdateEventListener(
        "job_update",
        onJobUpdate("transfer_tracks", ({ data }) => {
          if (data.transferId !== transfer.id) return;
          setTransferJobOffset(data.currentIndex);

          if (data.status === "done" && refetchTransfers) {
            refetchTransfers().finally(() => setTransferJobOffset(undefined));
          }
        }),
      ),
    [],
  );

  return (
    <Stack
      w="full"
      flexDirection={["column", undefined, undefined, "row"]}
      justifyContent={["flex-start", undefined, undefined, "space-between"]}
      key={transfer.id}
      alignItems="flex-start"
      gap="4"
      borderRadius="sm"
      borderWidth="thin"
      borderStyle="solid"
      borderColor="gray.1"
      p="4"
      boxShadow="xs"
    >
      <Stack gap="0">
        <Badge
          className={statusStyle({ theme: status })}
          variant="solid"
          width="fit-content"
          mb="2"
        >
          {statusText}
        </Badge>
        <HStack w="full">
          <HStack gap="1">
            <PlatformLogo
              platform={transfer.sourcePlaylist.platformName}
              className={css({ h: "4", w: "auto" })}
            />

            <PlatformLogo
              platform={transfer.destination}
              className={css({ h: "4", w: "auto" })}
            />
          </HStack>
          <Heading as="h2" size="md">
            Library transfer from{" "}
            {getPlatformName(transfer.sourcePlaylist.platformName)} to{" "}
            {getPlatformName(transfer.destination)}
          </Heading>
        </HStack>

        <Text color="gray.9" textStyle="sm" mb="2">
          Started on {formatDateTime(transfer.insertedAt)}
        </Text>

        {status === "wait-for-confirmation" && (
          <ThemedAlert
            severity="info"
            description={`Out of ${transfer.sourcePlaylist.tracksTotal} tracks, ${transfer.matchedTracks} were found and ${transfer.notFoundTracks} were not found. Confirm the transfer to proceed.`}
          />
        )}

        {searchJobOffset != null &&
          transfer.sourcePlaylist.tracksTotal != null && (
            <TransferProgress
              current={searchJobOffset}
              max={transfer.sourcePlaylist.tracksTotal}
              progressText={(current, max) =>
                `Matching track #${current} of ${max}`
              }
            />
          )}

        {transferJobOffset != null && (
          <TransferProgress
            current={transferJobOffset}
            max={transfer.matchedTracks}
            progressText={(current, max) =>
              `Transfering track #${current} of ${max}`
            }
          />
        )}
      </Stack>

      <HStack alignSelf={[undefined, undefined, undefined, "center"]}>
        {canConfirm && (
          <Button
            size="sm"
            loading={isConfirmTransferPending}
            disabled={isConfirmTransferPending}
            onClick={handleConfirmTransfer}
          >
            Confirm your transfer
          </Button>
        )}
        {canCancel && (
          <Button
            size="sm"
            loading={isCancelTransferPending}
            disabled={isCancelTransferPending}
            onClick={handleCancelTransfer}
          >
            Cancel
          </Button>
        )}
      </HStack>
    </Stack>
  );
}
