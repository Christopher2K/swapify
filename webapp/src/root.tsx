import type { PropsWithChildren } from "react";
import { TamaguiProvider } from "@tamagui/core";
import { QueryClientProvider } from "@tanstack/react-query";

import { queryClient, tsr } from "#root/services/api";
import config from "../tamagui.config";

export type RootProps = PropsWithChildren;

export function Root({ children }: RootProps) {
  return (
    <QueryClientProvider client={queryClient}>
      <tsr.ReactQueryProvider>
        <TamaguiProvider config={config}>{children}</TamaguiProvider>
      </tsr.ReactQueryProvider>
    </QueryClientProvider>
  );
}
