import { tsr } from "#root/services/api";
import { handleApiError } from "#root/services/api.utils";

export function useStartLibrarySyncMutation() {
  const { mutateAsync: startLibrarySyncJobAsync, isPending } =
    tsr.startSyncLibraryJob.useMutation({
      onError: handleApiError,
    });

  return {
    startLibrarySyncJobAsync,
    isPending,
  };
}
