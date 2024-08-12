import type { PropsWithChildren } from "react";

import { QueryClientProvider } from "@tanstack/react-query";

import { Container } from "#root/components/container";
import { queryClient, tsr } from "#root/services/api";

export type RootProps = PropsWithChildren;

export function Root({ children }: RootProps) {
  return (
    <QueryClientProvider client={queryClient}>
      <tsr.ReactQueryProvider>
        <Container>{children}</Container>
      </tsr.ReactQueryProvider>
    </QueryClientProvider>
  );
}
