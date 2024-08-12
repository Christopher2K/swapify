import { tsr } from "#root/services/api";

export function useSigninMutation() {
  const { mutateAsync: signinAsync } = tsr.signinUser.useMutation({});
  return signinAsync;
}
