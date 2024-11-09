import { createTsForm, createUniqueFieldSchema } from "@ts-react/form";
import { PropsWithChildren } from "react";
import { z } from "zod";

import { css } from "#style/css";
import { vstack } from "#style/patterns";

import { Button } from "./ui/button";

import { APIPlatformNameSchema } from "#root/services/api.types";
import { SelectField } from "./select-field";
import { PasswordField, TextField } from "./textfield";
import { ThemedAlert } from "./themed-alert";

export const PasswordSchema = createUniqueFieldSchema(
  z.string().min(8, "Password must be at least 8 characters"),
  "password",
);

export const UncheckedPasswordSchema = createUniqueFieldSchema(
  z.string(),
  "password",
);

export const PlatformNameSchema = createUniqueFieldSchema(
  APIPlatformNameSchema,
  "platform",
);

export const SelectSchema = createUniqueFieldSchema(z.string(), "select");

const mapping = [
  [z.string(), TextField] as const,
  [PasswordSchema, PasswordField] as const,
  [PlatformNameSchema, SelectField] as const,
  [SelectSchema, SelectField] as const,
] as const;

const defaultFormItemsContainerClassName = css({
  w: "full",
  display: "flex",
  flexDirection: "column",
  justifyContent: "flex-start",
  alignItems: "flex-start",
  gap: "6",
});

type SchemaFormContainerProps = PropsWithChildren<{
  id?: string;
  formItemsContainerClassName?: string;
  submitText?: string;
  isLoading?: boolean;
  hideSubmitButton?: boolean;
  isSubmitDisabled?: boolean;
  globalError?: string;
  onSubmit: () => void;
}>;
export function SchemaFormContainer({
  id,
  submitText = "Submit",
  isLoading,
  isSubmitDisabled,
  hideSubmitButton = false,
  globalError,
  onSubmit,
  formItemsContainerClassName = defaultFormItemsContainerClassName,
  children,
}: SchemaFormContainerProps) {
  return (
    <form
      id={id}
      onSubmit={onSubmit}
      className={vstack({
        w: "full",
        gap: "6",
        containerType: "inline-size",
      })}
    >
      {globalError && (
        <ThemedAlert title="Error" description={globalError} severity="error" />
      )}
      <div className={formItemsContainerClassName}>{children}</div>
      {!hideSubmitButton && (
        <Button
          loading={isLoading}
          type="submit"
          w="full"
          size="xl"
          disabled={isSubmitDisabled}
        >
          {submitText}
        </Button>
      )}
    </form>
  );
}

export const SchemaForm = createTsForm(mapping, {
  FormComponent: SchemaFormContainer,
} as const);
