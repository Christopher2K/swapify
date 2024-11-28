import type { PropsWithChildren } from "react";

import { ContentContainer } from "#root/features/marketing/components/content-container";

export function Container({ children }: PropsWithChildren) {
  return <ContentContainer>{children}</ContentContainer>;
}
