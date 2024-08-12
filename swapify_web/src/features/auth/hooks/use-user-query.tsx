import { tsr } from "#root/services/api";

export function useUserQuery() {
  const { data, isLoading, isError, refetch } = tsr.getUser.useQuery({
    refetchOnMount: false,
    retry: 0,
    queryKey: ["user"],
  });

  return {
    user: data?.status === 200 ? data?.body.data : undefined,
    isError,
    isLoading,
    refetch,
  };
}
