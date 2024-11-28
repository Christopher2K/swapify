import type { PropsWithChildren } from "react";

import { Stack } from "#style/jsx";

export function Container({ children }: PropsWithChildren) {
  return (
    <Stack
      position="relative"
      w="100%"
      gap="0"
      px="4"
      minHeight="100vh"
      maxWidth="1200px"
      mx="auto"
    >
      {children}
    </Stack>
  );
}
