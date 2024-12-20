import { tsr } from "#root/services/api";
import { handleApiError } from "#root/services/api.utils";

export function useSignInMutation() {
  const queryClient = tsr.useQueryClient();

  const {
    mutateAsync: signInAsync,
    isPending,
    error,
  } = tsr.signinUser.useMutation({
    onSuccess: async () => {
      await queryClient.resetQueries();
    },
    onError: (error) => {
      handleApiError(error);
    },
  });

  return {
    signInAsync,
    isPending,
    error,
  };
}
