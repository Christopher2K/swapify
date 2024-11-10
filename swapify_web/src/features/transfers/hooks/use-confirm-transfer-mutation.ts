import { useCallback } from "react";

import { tsr } from "#root/services/api";
import { handleApiError } from "#root/services/api.utils";

export function useConfirmTransferMutation() {
  const queryClient = tsr.useQueryClient();

  const { isPending, mutateAsync } = tsr.confirmPlaylistTransfer.useMutation({
    onSuccess: async () => {
      await queryClient.invalidateQueries();
    },
    onError: (error) => {
      handleApiError(error);
    },
  });

  const confirmTransferAsync = useCallback(
    async (transferId: string) => {
      await mutateAsync({ params: { transferId } });
    },
    [mutateAsync],
  );

  return { confirmTransferAsync, isPending };
}
