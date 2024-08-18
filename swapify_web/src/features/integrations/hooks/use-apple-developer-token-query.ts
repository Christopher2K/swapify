import { tsr } from "#root/services/api";

export function useAppleDeveloperTokenQuery() {
  const { data, isLoading, isError, refetch } =
    tsr.getAppleMusicDeveloperToken.useQuery({
      refetchOnMount: false,
      retry: 0,
      queryKey: ["apple-developer-token"],
    });

  return {
    data: data?.status === 200 ? data?.body.data : undefined,
    isError,
    isLoading,
    refetch,
  };
}
