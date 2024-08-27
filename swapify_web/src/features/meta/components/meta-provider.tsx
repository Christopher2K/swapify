import { useContext, createContext, PropsWithChildren } from "react";

import type { APIMeta } from "#root/services/api.types";

import { useMetaQuery } from "../hooks/use-meta-query";

const MetaContext = createContext<null | APIMeta>(null);

export function MetaProvider({ children }: PropsWithChildren) {
  const { meta, isLoading } = useMetaQuery();

  if (isLoading || !meta) {
    return null;
  }

  return <MetaContext.Provider value={meta}>{children}</MetaContext.Provider>;
}

export function useMeta() {
  const ctx = useContext(MetaContext);
  if (ctx == null) {
    throw new Error("useMeta must be used within a MetaProvider");
  }
  return ctx;
}
