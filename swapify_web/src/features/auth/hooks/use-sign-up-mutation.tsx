import { tsr } from "#root/services/api";
import { handleApiError } from "#root/services/api.utils";

export function useSignUpMutation() {
  const {
    mutateAsync: signUpAsync,
    isPending,
    error,
    contractEndpoint,
  } = tsr.signupUser.useMutation({
    onError: (error) => {
      handleApiError(error);
    },
  });

  return {
    signUpAsync,
    isPending,
    error,
    contractEndpoint,
  };
}
