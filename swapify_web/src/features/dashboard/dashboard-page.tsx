import { VStack } from "#style/jsx";

import { Onboarding } from "./components/onboarding";

export function DashboardPage() {
  return (
    <VStack
      w="full"
      p="4"
      gap="10"
      justifyContent="flex-start"
      alignItems="flex-start"
    >
      <Onboarding />
    </VStack>
  );
}
