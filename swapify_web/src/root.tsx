import type { PropsWithChildren } from "react";

import { QueryClientProvider } from "@tanstack/react-query";

import { ToastRoot } from "#root/components/toast";
import { queryClient, tsr } from "#root/services/api";

export type RootProps = PropsWithChildren;

export function Root({ children }: RootProps) {
  return (
    <QueryClientProvider client={queryClient}>
      <ToastRoot />
      <tsr.ReactQueryProvider>{children}</tsr.ReactQueryProvider>
    </QueryClientProvider>
  );
}
