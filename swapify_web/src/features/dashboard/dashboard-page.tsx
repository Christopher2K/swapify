import { Stack, HStack, VStack } from "#style/jsx";

import { Heading } from "#root/components/ui/heading";
import { useTransfersQuery } from "#root/features/transfers/hooks/use-transfers-query";

import { PlatformLogo } from "#root/components/platform-logo";
import { Text } from "#root/components/ui/text";
import { formatDateTime } from "#root/utils/date";
import { Button } from "#root/components/ui/button";
import { APITransfer } from "#root/services/api.types";
import { getPlatformName } from "#root/features/integrations/utils/get-platform-name";
import { css, cva } from "#style/css";

import { Onboarding } from "./components/onboarding";
import { Badge } from "#root/components/ui/badge";

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
};
function TransferRow({ transfer }: TransferRowProps) {
  const status = getTransferStatus(transfer);
  const canCancel = status === "wait-for-confirmation";
  const canConfirm = status === "wait-for-confirmation";
  const statusText = getTransferStatusText(status);

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
      </Stack>

      <HStack alignSelf={[undefined, undefined, undefined, "center"]}>
        {canConfirm && <Button size="sm">Confirm your transfer</Button>}
        {canCancel && <Button size="sm">Cancel</Button>}
      </HStack>
    </Stack>
  );
}

export function DashboardPage() {
  const { transfers } = useTransfersQuery();
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

      {shouldShowOnboarding && (
        <VStack
          w="full"
          justifyContent="flex-start"
          alignItems="flex-start"
          gap="4"
        >
          <Onboarding />
        </VStack>
      )}

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
          <TransferRow key={transfer.id} transfer={transfer} />
        ))}
      </VStack>
    </VStack>
  );
}
