import { tsr } from "#root/services/api";
import { APIPlatformName } from "#root/services/api.types";

export const QUERY_KEY = "libraries";

export function useLibrariesQuery(platformName?: APIPlatformName) {
  const { data, isError, isLoading, refetch } =
    tsr.searchUserLibraries.useQuery({
      queryData: {
        query: {
          platform: platformName,
        },
      },
      refetchOnMount: false,
      retry: 0,
      queryKey: platformName ? [QUERY_KEY, platformName] : [QUERY_KEY],
    });

  return {
    playlists: data?.status === 200 ? data?.body.data : undefined,
    isError,
    isLoading,
    refetch,
  };
}
