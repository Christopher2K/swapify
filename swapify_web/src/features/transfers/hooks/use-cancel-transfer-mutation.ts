import { useCallback } from "react";

import { tsr } from "#root/services/api";

export function useCancelTransferMutation() {
  const queryClient = tsr.useQueryClient();

  const { isPending, mutateAsync } = tsr.cancelPlaylistTransfer.useMutation({
    onSuccess: async () => {
      await queryClient.invalidateQueries();
    },
    onError: (_) => {
      // TODO: Handle error with a generic handler
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
