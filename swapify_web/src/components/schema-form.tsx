import { PropsWithChildren } from "react";
import { z } from "zod";
import { createTsForm, createUniqueFieldSchema } from "@ts-react/form";

import { vstack } from "#style/patterns";

import { Button } from "./ui/button";
import { Alert } from "./ui/alert";

import { TextField, PasswordField } from "./textfield";
import { ThemedAlert } from "./themed-alert";

export const PasswordSchema = createUniqueFieldSchema(
  z.string().min(8, "Password must be at least 8 characters"),
  "password",
);

export const UncheckedPasswordSchema = createUniqueFieldSchema(
  z.string(),
  "password",
);

const mapping = [
  [z.string(), TextField] as const,
  [PasswordSchema, PasswordField] as const,
] as const;

type SchemaFormContainerProps = PropsWithChildren<{
  id?: string;
  submitText?: string;
  isLoading?: boolean;
  hideSubmitButton?: boolean;
  globalError?: string;
  onSubmit: () => void;
}>;
export function SchemaFormContainer({
  id,
  submitText,
  isLoading,
  hideSubmitButton = false,
  globalError,
  onSubmit,
  children,
}: SchemaFormContainerProps) {
  return (
    <form
      id={id}
      onSubmit={onSubmit}
      className={vstack({
        w: "full",
        gap: "6",
      })}
    >
      {globalError && (
        <ThemedAlert title="Error" description={globalError} severity="error" />
      )}
      {children}
      {!hideSubmitButton && (
        <Button loading={isLoading} type="submit" w="full" size="xl">
          {submitText}
        </Button>
      )}
    </form>
  );
}

export const SchemaForm = createTsForm(mapping, {
  FormComponent: SchemaFormContainer,
} as const);
