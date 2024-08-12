import { tsr } from "#root/services/api";

export function useSignupMutation() {
  const {
    mutateAsync: signupAsync,
    isPending,
    error,
  } = tsr.signupUser.useMutation({});

  return { signupAsync, isLoading: isPending, error };
}
