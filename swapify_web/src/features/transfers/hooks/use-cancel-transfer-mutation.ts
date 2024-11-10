import { useCallback } from "react";

import { tsr } from "#root/services/api";
import { handleApiError } from "#root/services/api.utils";

export function useCancelTransferMutation() {
  const queryClient = tsr.useQueryClient();

  const { isPending, mutateAsync } = tsr.cancelPlaylistTransfer.useMutation({
    onSuccess: async () => {
      await queryClient.invalidateQueries();
    },
    onError: (error) => {
      handleApiError(error);
    },
  });

  const cancelTransferAsync = useCallback(
    async (transferId: string) => {
      await mutateAsync({ params: { transferId } });
    },
    [mutateAsync],
  );

  return { cancelTransferAsync, isPending };
}
