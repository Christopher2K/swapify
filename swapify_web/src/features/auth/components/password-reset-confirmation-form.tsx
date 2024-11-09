import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { SchemaForm, PasswordSchema } from "#root/components/schema-form";

export const PASSWORD_RESET_CONFIRMATION_FORM_ID =
  "password-reset-confirmation-form";

const PasswordResetConfirmationFormSchema = z
  .object({
    password: PasswordSchema.describe(
      "Password // Enter a new password for your account",
    ),
    passwordConfirmation: PasswordSchema.describe(
      "Password confirmation // Enter the same password as above",
    ),
  })
  .refine(
    (values) => {
      return values.password === values.passwordConfirmation;
    },
    {
      message: "Passwords don't match",
      path: ["passwordConfirmation"],
    },
  );

export type PasswordResetConfirmationFormData = z.infer<
  typeof PasswordResetConfirmationFormSchema
>;

type PasswordResetConfirmationFormProps = {
  form?: ReturnType<typeof usePasswordResetConfirmationForm>;
  isLoading?: boolean;
  isSubmitDisabled?: boolean;
  handleSubmit: (
    data: z.infer<typeof PasswordResetConfirmationFormSchema>,
  ) => void;
};

export function PasswordResetConfirmationForm({
  form,
  isLoading,
  handleSubmit,
  isSubmitDisabled,
}: PasswordResetConfirmationFormProps) {
  return (
    <SchemaForm
      schema={PasswordResetConfirmationFormSchema}
      form={form}
      onSubmit={handleSubmit}
      formProps={{
        isLoading,
        id: PASSWORD_RESET_CONFIRMATION_FORM_ID,
        isSubmitDisabled,
      }}
    />
  );
}

export function usePasswordResetConfirmationForm() {
  return useForm<PasswordResetConfirmationFormData>({
    resolver: zodResolver(PasswordResetConfirmationFormSchema),
  });
}
