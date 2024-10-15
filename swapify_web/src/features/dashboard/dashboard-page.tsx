import { VStack } from "#style/jsx";

import { useTransfersQuery } from "#root/features/transfers/hooks/use-transfers-query";

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
      {shouldShowOnboarding && <Onboarding />}
    </VStack>
  );
}
