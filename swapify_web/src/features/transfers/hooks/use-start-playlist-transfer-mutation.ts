import { tsr } from "#root/services/api";

export function useStartPlaylistTransferMutation() {
  const queryClient = tsr.useQueryClient();
  const { isPending, mutateAsync: startPlaylistTransferAsync } =
    tsr.startPlaylistTransfer.useMutation({
      onSuccess: async () => {
        await queryClient.invalidateQueries();
      },
      onError: (_) => {
        // TODO: Handle error with a generic handler
      },
    });

  return { startPlaylistTransferAsync, isPending };
}
