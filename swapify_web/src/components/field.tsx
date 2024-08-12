import { PropsWithChildren } from "react";

import { Field as BaseField } from "./ui/field";

export type FieldProps = PropsWithChildren<{
  htmlFor?: string;
  label?: string;
  error?: string;
  helperText?: string;
}>;

export function Field({
  children,
  label,
  error,
  htmlFor,
  helperText,
}: FieldProps) {
  return (
    <BaseField.Root w="full" invalid={Boolean(error)}>
      {label && <BaseField.Label htmlFor={htmlFor}>{label}</BaseField.Label>}
      <BaseField.Input asChild>{children}</BaseField.Input>
      {helperText && <BaseField.HelperText>{helperText}</BaseField.HelperText>}
      {error && <BaseField.ErrorText>{error}</BaseField.ErrorText>}
    </BaseField.Root>
  );
}
