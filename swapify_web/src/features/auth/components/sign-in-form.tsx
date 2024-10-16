import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";

import {
  SchemaForm,
  UncheckedPasswordSchema,
} from "#root/components/schema-form";

export const SIGN_IN_FORM_ID = "sign-in-form";

const SignInFormSchema = z.object({
  email: z.string().email().describe("Email // e.g. chris@llcoolchris.dev"),
  password: UncheckedPasswordSchema.describe("Password"),
});

export type SignInFormData = z.infer<typeof SignInFormSchema>;

export type SignInFormProps = {
  form?: ReturnType<typeof useSignInForm>;
  isLoading?: boolean;
  handleSubmit: (data: z.infer<typeof SignInFormSchema>) => void;
};

export function SignInForm({ form, handleSubmit, isLoading }: SignInFormProps) {
  return (
    <SchemaForm
      form={form}
      schema={SignInFormSchema}
      onSubmit={handleSubmit}
      formProps={{
        globalError: form?.formState.errors.root?.message,
        isLoading,
        submitText: "Sign in",
        id: SIGN_IN_FORM_ID,
      }}
    />
  );
}

export function useSignInForm() {
  return useForm<SignInFormData>({
    resolver: zodResolver(SignInFormSchema),
  });
}
