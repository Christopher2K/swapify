import { tsr } from "#root/services/api";

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
  });

  return {
    signInAsync,
    isPending,
    error,
  };
}
