import { useEffect, useState } from "react";

import { Heading } from "#root/components/ui/heading";
import { useTransfersQuery } from "#root/features/transfers/hooks/use-transfers-query";

import { PlatformLogo } from "#root/components/platform-logo";
import { Badge } from "#root/components/ui/badge";
import { Button } from "#root/components/ui/button";
import { Progress } from "#root/components/ui/progress";
import { Text } from "#root/components/ui/text";
import { getPlatformName } from "#root/features/integrations/utils/get-platform-name";
import { APITransfer } from "#root/services/api.types";
import { formatDateTime } from "#root/utils/date";
import { css, cva } from "#style/css";
import { HStack, Stack, VStack } from "#style/jsx";

import { useJobUpdateContext } from "../job/components/job-update-context";
import { onJobUpdate } from "../job/utils/on-job-update";
import { Onboarding } from "./components/onboarding";

type TransferStatus =
  | "matching"
  | "wait-for-confirmation"
  | "transfering"
  | "cancelled"
  | "done"
  | "error";

function getTransferStatus(transfer: APITransfer): TransferStatus {
  if (
    transfer.matchingStepJob?.status === "error" ||
    transfer.transferStepJob?.status === "error"
  ) {
    return "error";
  }

  if (
    transfer.matchingStepJob?.status === "done" &&
    transfer.transferStepJob?.status === "done"
  ) {
    return "done";
  }

  if (
    transfer.matchingStepJob?.status === "done" &&
    !transfer.transferStepJob
  ) {
    return "wait-for-confirmation";
  }

  if (transfer.transferStepJob?.status === "started") {
    return "transfering";
  }

  return "matching";
}

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
      return "Maching";
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
  refetchTransfers?: () => Promise<void>;
};
function TransferRow({ transfer, refetchTransfers }: TransferRowProps) {
  const { addJobUpdateEventListener } = useJobUpdateContext();
  const [searchJobOffset, setSearchJobOffset] = useState<number | undefined>(
    undefined,
  );

  const status = getTransferStatus(transfer);
  const canCancel = status === "wait-for-confirmation";
  const canConfirm = status === "wait-for-confirmation";
  const statusText = getTransferStatusText(status);

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

        {searchJobOffset !== undefined && (
          <VStack justifyContent="flex-start" alignItems="flex-start" gap="0">
            <Text color="gray.9" textStyle="sm" mb="2" fontWeight="medium">
              Matching track #{searchJobOffset} of{" "}
              {transfer.sourcePlaylist.tracksTotal}
            </Text>
            <Progress
              translations={{ value: () => "" }}
              min={0}
              max={transfer.sourcePlaylist.tracksTotal}
              value={searchJobOffset}
            />
          </VStack>
        )}
      </Stack>

      <span></span>

      <HStack alignSelf={[undefined, undefined, undefined, "center"]}>
        {canConfirm && <Button size="sm">Confirm your transfer</Button>}
        {canCancel && <Button size="sm">Cancel</Button>}
      </HStack>
    </Stack>
  );
}

export function DashboardPage() {
  const { transfers, refetch } = useTransfersQuery();
  const shouldShowOnboarding = transfers && transfers.length === 0;

  const transfersInProgress =
    transfers?.filter((transfer) => {
      const status = getTransferStatus(transfer);
      return (
        status === "matching" ||
        status === "transfering" ||
        status === "wait-for-confirmation"
      );
    }) ?? [];

  return (
    <VStack
      w="full"
      p="4"
      gap="10"
      justifyContent="flex-start"
      alignItems="flex-start"
    >
      <VStack
        w="full"
        justifyContent="flex-start"
        alignItems="flex-start"
        gap="4"
      >
        <Heading as="h1" size="xl">
          Dashboard
        </Heading>
      </VStack>

      {shouldShowOnboarding ? (
        <VStack
          w="full"
          justifyContent="flex-start"
          alignItems="flex-start"
          gap="4"
        >
          <Onboarding />
        </VStack>
      ) : (
        <VStack
          w="full"
          justifyContent="flex-start"
          alignItems="flex-start"
          gap="4"
        >
          <Heading as="h1" size="xl">
            Transfers in progress
          </Heading>

          {transfersInProgress.map((transfer) => (
            <TransferRow
              key={transfer.id}
              transfer={transfer}
              refetchTransfers={refetch}
            />
          ))}
        </VStack>
      )}
    </VStack>
  );
}
