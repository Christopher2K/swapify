import { tsr } from "#root/services/api";

export const QUERY_KEY = "transfers";

export function useTransfersQuery() {
  const { data, isLoading, isError, refetch } =
    tsr.searchPlaylistTransfers.useQuery({
      queryKey: [QUERY_KEY],
      refetchOnMount: false,
      retry: 0,
    });

  return {
    transfers: data?.status === 200 ? data?.body.data : undefined,
    isError,
    isLoading,
    refetch,
  };
}
