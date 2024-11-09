import { tsr } from "#root/services/api";

import { handleApiError } from "#root/services/api.utils";

export function usePasswordResetRequestMutation() {
  const {
    mutateAsync: passwordResetRequestAsync,
    isPending,
    isSuccess,
    error,
  } = tsr.passwordResetRequest.useMutation({
    onError: (error) => {
      handleApiError(error);
    },
  });

  return {
    passwordResetRequestAsync,
    isPending,
    isSuccess,
    error,
  };
}
