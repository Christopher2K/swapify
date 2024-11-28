import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { PasswordSchema, SchemaForm } from "#root/components/schema-form";

export const SIGN_UP_FORM_ID = "sign-up-form";

const SignUpFormSchema = z.object({
  username: z.string().min(2).max(20).describe("Username // e.g. llCoolChris_"),
  email: z.string().email().describe("Email // e.g. chris@llcoolchris.dev"),
  password: PasswordSchema.describe("Password"),
  spotifyAccountEmail: z
    .string()
    .email()
    .optional()
    .describe("Spotify account email"),
});
export type SignUpFormData = z.infer<typeof SignUpFormSchema>;

export type SignUpFormProps = {
  form?: ReturnType<typeof useSignUpForm>;
  isLoading?: boolean;
  handleSubmit: (data: z.infer<typeof SignUpFormSchema>) => void;
};

export function SignUpForm({ isLoading, handleSubmit, form }: SignUpFormProps) {
  return (
    <SchemaForm
      form={form}
      schema={SignUpFormSchema}
      props={{
        password: {
          helperText: "Password must be at least 8 characters",
        },
        spotifyAccountEmail: {
          helperText:
            "We need your Spotify account email for the beta program, since Spotify has not approved out app yet!",
        },
      }}
      onSubmit={handleSubmit}
      formProps={{
        submitText: "Sign up",
        isLoading,
        id: SIGN_UP_FORM_ID,
      }}
    />
  );
}

export function useSignUpForm() {
  return useForm<SignUpFormData>({
    resolver: zodResolver(SignUpFormSchema),
  });
}
