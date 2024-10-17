import { Heading } from "#root/components/ui/heading";
import { VStack } from "#style/jsx";

import { TransfersList } from "./components/tranfers-list";
import { useTransfersQuery } from "./hooks/use-transfers-query";

export function TransfersPage() {
  const { transfers } = useTransfersQuery();

  return (
    <VStack
      w="full"
      h="auto"
      p="4"
      gap="5"
      justifyContent="flex-start"
      alignItems="flex-start"
    >
      {/* @ts-expect-error */}
      <VStack as="header" justifyContent="flex-start" alignItems="flex-start">
        <Heading as="h1" size="xl">
          Transfers
        </Heading>
      </VStack>
      <TransfersList transfers={transfers} />
    </VStack>
  );
}
