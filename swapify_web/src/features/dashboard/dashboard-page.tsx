import { Heading } from "#root/components/ui/heading";
import { useTransfersQuery } from "#root/features/transfers/hooks/use-transfers-query";

import { TransferRow } from "#root/features/transfers/components/transfer-item";
import { getTransferStatus } from "#root/features/transfers/transfers.utils";
import { VStack } from "#style/jsx";

import { Onboarding } from "./components/onboarding";

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
