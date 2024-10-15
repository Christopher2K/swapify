import { VStack } from "#style/jsx";

import { Heading } from "#root/components/ui/heading";
import { useTransfersQuery } from "#root/features/transfers/hooks/use-transfers-query";
import { useUserQuery } from "#root/features/auth/hooks/use-user-query";

import { Onboarding } from "./components/onboarding";

export function DashboardPage() {
  const { transfers } = useTransfersQuery();
  const shouldShowOnboarding = transfers && transfers.length === 0;

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
          Transfers
        </Heading>
      </VStack>
    </VStack>
  );
}
