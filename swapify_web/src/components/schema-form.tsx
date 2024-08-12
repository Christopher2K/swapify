import { PropsWithChildren } from "react";
import { z } from "zod";
import { createTsForm, createUniqueFieldSchema } from "@ts-react/form";

import { vstack } from "#style/patterns";

import { Button } from "./ui/button";
import { TextField, PasswordField } from "./textfield";

export const PasswordSchema = createUniqueFieldSchema(
  z.string().min(8, "Password must be at least 8 characters"),
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
  onSubmit: () => void;
}>;
export function SchemaFormContainer({
  id,
  submitText,
  isLoading,
  hideSubmitButton = false,
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
