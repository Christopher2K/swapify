import { Heading } from "#root/components/ui/heading";
import { useTransfersQuery } from "#root/features/transfers/hooks/use-transfers-query";

import { getTransferStatus } from "#root/features/transfers/transfers.utils";
import { TransfersList } from "#root/features/transfers/components/tranfers-list";
import { HStack, VStack } from "#style/jsx";
import { APITransfer } from "#root/services/api.types";
import { CreateTransferButton } from "#root/features/transfers/components/create-transfer-button";

import { Onboarding } from "./components/onboarding";

function isTransferInProgress(transfer: APITransfer) {
  const status = getTransferStatus(transfer);
  return (
    status === "matching" ||
    status === "transfering" ||
    status === "wait-for-confirmation"
  );
}

export function DashboardPage() {
  const { transfers, refetch } = useTransfersQuery();
  const shouldShowOnboarding = transfers && transfers.length === 0;

  return (
    <VStack
      w="full"
      p="4"
      gap="5"
      justifyContent="flex-start"
      alignItems="flex-start"
    >
      <HStack
        w="full"
        justifyContent="space-between"
        alignItems="center"
        gap="4"
        flexWrap="wrap"
      >
        <Heading as="h1" size="xl">
          Dashboard
        </Heading>
        {!shouldShowOnboarding && <CreateTransferButton />}
      </HStack>

      <VStack
        w="full"
        justifyContent="flex-start"
        alignItems="flex-start"
        gap="4"
      >
        {shouldShowOnboarding ? (
          <Onboarding />
        ) : (
          <>
            <Heading as="h2" size="lg">
              Transfers in progress
            </Heading>

            <TransfersList
              transfers={transfers}
              predicate={isTransferInProgress}
              refetchList={refetch}
            />
          </>
        )}
      </VStack>
    </VStack>
  );
}
