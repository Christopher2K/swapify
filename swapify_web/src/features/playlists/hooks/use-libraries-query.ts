import { tsr } from "#root/services/api";
import {
  APIPlatformName,
  APIPlaylistSyncStatus,
} from "#root/services/api.types";

export const QUERY_KEY = "libraries";

export function useLibrariesQuery({
  platformName,
  status,
}: {
  platformName?: APIPlatformName;
  status?: APIPlaylistSyncStatus[];
} = {}) {
  const { data, isError, isLoading, refetch } =
    tsr.searchUserLibraries.useQuery({
      queryData: {
        query: {
          platform: platformName,
          status,
        },
      },
      refetchOnMount: false,
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
