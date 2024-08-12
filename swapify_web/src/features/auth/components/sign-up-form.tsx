import { z } from "zod";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";

import { SchemaForm, PasswordSchema } from "#root/components/schema-form";

export const SIGN_UP_FORM_ID = "sign-up-form";

const SignUpFormSchema = z.object({
  username: z.string().describe("Username // e.g. llCoolChris_"),
  email: z.string().email().describe("Email // e.g. chris@llcoolchris.dev"),
  password: PasswordSchema.describe("Password"),
});
export type SignUpFormData = z.infer<typeof SignUpFormSchema>;

export type SignUpFormProps = {
  form?: ReturnType<typeof useSignUpForm>;
  isLoading?: boolean;
  handleSubmit: (data: z.infer<typeof SignUpFormSchema>) => void;
  hideSubmitButton?: boolean;
};

export function SignUpForm({
  isLoading,
  handleSubmit,
  form,
  hideSubmitButton,
}: SignUpFormProps) {
  return (
    <SchemaForm
      form={form}
      schema={SignUpFormSchema}
      props={{
        password: {
          helperText: "Password must be at least 8 characters",
        },
      }}
      onSubmit={handleSubmit}
      formProps={{
        submitText: "Sign up",
        isLoading,
        id: SIGN_UP_FORM_ID,
        hideSubmitButton,
      }}
    />
  );
}

export function useSignUpForm() {
  return useForm<SignUpFormData>({
    resolver: zodResolver(SignUpFormSchema),
  });
}
