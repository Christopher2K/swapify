import { tsr } from "#root/services/api";
import type {
  APIPlatformName,
  APIPlaylistSyncStatus,
} from "#root/services/api.types";

export const QUERY_KEY = "libraries";

export function useLibrariesQuery({
  platformName,
  status,
  // This should not be exposed. It should be replaced by the invalidation mechanism
  refetchOnMount,
}: {
  platformName?: APIPlatformName;
  status?: APIPlaylistSyncStatus[];
  refetchOnMount?: boolean;
} = {}) {
  const { data, isError, isLoading, refetch } =
    tsr.searchUserLibraries.useQuery({
      queryData: {
        query: {
          platform: platformName,
          status,
        },
      },
      refetchOnMount,
      retry: 0,
      queryKey: [QUERY_KEY, platformName, status],
    });

  return {
    libraries: data?.status === 200 ? data?.body.data : undefined,
    isError,
    isLoading,
    refetch,
  };
}
