import type { PropsWithChildren } from "react";

import { Spinner } from "#root/components/ui/spinner";
import { VStack } from "#style/jsx";

export function LoadingContainer({ children }: PropsWithChildren) {
  return (
    <VStack
      position="absolute"
      top="0"
      left="0"
      right="0"
      bottom="0"
      w="full"
      h="full"
      justifyContent="center"
      alignItems="center"
      gap="4"
    >
      <Spinner />
      {children}
    </VStack>
  );
}
