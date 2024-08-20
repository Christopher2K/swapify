import { tsr } from "#root/services/api";

export const QUERY_KEY = "integrations";

export function useIntegrationsQuery() {
  const { data, isLoading, isError, refetch } = tsr.getIntegrations.useQuery({
    refetchOnMount: false,
    retry: 0,
    queryKey: [QUERY_KEY],
  });

  return {
    integrations: data?.status === 200 ? data?.body.data : undefined,
    isError,
    isLoading,
    refetch,
  };
}
