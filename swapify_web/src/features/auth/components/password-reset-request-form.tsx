import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { SchemaForm } from "#root/components/schema-form";

export const PASSWORD_RESET_REQUEST_FORM_ID = "password-reset-request-form";

const PasswordResetRequestFormSchema = z.object({
  email: z.string().email().describe("Email // e.g. chris@llcoolchris.dev"),
});

export type PasswordResetRequestFormData = z.infer<
  typeof PasswordResetRequestFormSchema
>;

type PasswordResetRequestFormProps = {
  form?: ReturnType<typeof usePasswordResetRequestForm>;
  isLoading?: boolean;
  isSubmitDisabled?: boolean;
  handleSubmit: (data: z.infer<typeof PasswordResetRequestFormSchema>) => void;
};

export function PasswordResetRequestForm({
  form,
  isLoading,
  handleSubmit,
  isSubmitDisabled,
}: PasswordResetRequestFormProps) {
  return (
    <SchemaForm
      schema={PasswordResetRequestFormSchema}
      form={form}
      onSubmit={handleSubmit}
      formProps={{
        isLoading,
        id: PASSWORD_RESET_REQUEST_FORM_ID,
        isSubmitDisabled,
      }}
    />
  );
}

export function usePasswordResetRequestForm() {
  return useForm<PasswordResetRequestFormData>({
    resolver: zodResolver(PasswordResetRequestFormSchema),
  });
}
