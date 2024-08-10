import { tsr } from "#root/services/api";

export function useSignupMutation() {
  const { mutateAsync: signupAsync } = tsr.signupUser.useMutation({});
  return signupAsync;
}
