import { tsr } from "#root/services/api";

import { handleApiError } from "#root/services/api.utils";

export function usePasswordResetConfirmationMutation() {
  const {
    mutateAsync: passwordResetConfirmationAsync,
    isPending,
    isSuccess,
    error,
  } = tsr.passwordResetConfirmation.useMutation({
    onError: (error) => {
      handleApiError(error);
    },
  });

  return {
    passwordResetConfirmationAsync,
    isPending,
    isSuccess,
    error,
  };
}
