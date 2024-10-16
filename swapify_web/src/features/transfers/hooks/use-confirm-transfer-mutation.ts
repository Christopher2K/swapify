import { useCallback } from "react";

import { tsr } from "#root/services/api";

export function useConfirmTransferMutation() {
  const queryClient = tsr.useQueryClient();

  const { isPending, mutateAsync } = tsr.confirmPlaylistTransfer.useMutation({
    onSuccess: async () => {
      await queryClient.invalidateQueries();
    },
    onError: (_) => {
      // TODO: Handle error with a generic handler
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
