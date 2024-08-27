import { tsr } from "#root/services/api";

const QUERY_KEY = "meta";

export function useMetaQuery() {
  const { data, isLoading, isError, refetch } = tsr.getMeta.useQuery({
    refetchOnMount: false,
    retry: 0,
    queryKey: [QUERY_KEY],
  });

  return {
    meta: data?.status === 200 ? data?.body.data : undefined,
    isError,
    isLoading,
    refetch,
  };
}
