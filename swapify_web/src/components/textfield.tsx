import { RefCallBack } from "react-hook-form";
import { useDescription, useTsController } from "@ts-react/form";

import { Field } from "./field";
import { Input, type InputProps } from "./ui/input";

export type TextFieldBaseProps = InputProps & {
  error?: string;
  label?: string;
  helperText?: string;
  innerRef?: RefCallBack;
};
export function TextFieldBase({
  error,
  label,
  helperText,
  innerRef,
  ...props
}: TextFieldBaseProps) {
  return (
    <Field
      error={error}
      label={label}
      htmlFor={props.id}
      helperText={helperText}
    >
      <Input ref={innerRef} {...props} />
    </Field>
  );
}

export function TextField(props: TextFieldBaseProps) {
  const { field, error } = useTsController<string>();
  const { label, placeholder } = useDescription();

  return (
    <TextFieldBase
      error={error?.errorMessage}
      label={label}
      placeholder={placeholder}
      innerRef={field.ref}
      id={field.name}
      value={field.value ?? ""}
      onChange={(e) => field.onChange(e.target.value)}
      onBlur={field.onBlur}
      disabled={field.disabled}
      {...props}
    />
  );
}

// Specialized TextField
export function PasswordField(props: TextFieldBaseProps) {
  return <TextField {...props} type="password" />;
}
