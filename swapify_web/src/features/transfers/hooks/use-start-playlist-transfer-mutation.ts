import { tsr } from "#root/services/api";
import { handleApiError } from "#root/services/api.utils";

export function useStartPlaylistTransferMutation() {
  const queryClient = tsr.useQueryClient();
  const { isPending, mutateAsync: startPlaylistTransferAsync } =
    tsr.startPlaylistTransfer.useMutation({
      onSuccess: async () => {
        await queryClient.invalidateQueries();
      },
      onError: (error) => {
        handleApiError(error);
      },
    });

  return { startPlaylistTransferAsync, isPending };
}
