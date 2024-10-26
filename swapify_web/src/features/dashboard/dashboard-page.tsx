import { useMemo } from "react";
import { Link } from "@tanstack/react-router";

import { CreateTransferButton } from "#root/features/transfers/components/create-transfer-button";
import { HStack, VStack } from "#style/jsx";
import { Heading } from "#root/components/ui/heading";
import { Button } from "#root/components/ui/button";
import { TransfersList } from "#root/features/transfers/components/tranfers-list";
import { useTransfersQuery } from "#root/features/transfers/hooks/use-transfers-query";

import { Onboarding } from "./components/onboarding";

function DashboardContent() {
  const { transfers, refetch } = useTransfersQuery();

  const threeLastTransfers = useMemo(() => transfers?.slice(0, 3), [transfers]);

  return (
    <VStack
      w="full"
      justifyContent="flex-start"
      alignItems="flex-start"
      gap="4"
    >
      <HStack w="full" justifyContent="flex-start" alignItems="center">
        <Heading as="h2" size="lg">
          Latest transfers
        </Heading>

        <Button size="xs" variant="outline" asChild>
          <Link to="/transfers">See all</Link>
        </Button>
      </HStack>
      <TransfersList transfers={threeLastTransfers} refetchList={refetch} />
    </VStack>
  );
}

export function DashboardPage() {
  const { transfers } = useTransfersQuery();
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
        gap="0"
      >
        {shouldShowOnboarding ? <Onboarding /> : <DashboardContent />}
      </VStack>
    </VStack>
  );
}
