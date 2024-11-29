import { useDescription, useTsController } from "@ts-react/form";
import type { RefCallBack } from "react-hook-form";

import { Field } from "./field";
import { Checkbox, type CheckboxProps } from "./ui/checkbox";

export type CheckboxFieldProps = CheckboxProps & {
  label?: string;
  helperText?: string;
  innerRef?: RefCallBack;
};
export function CheckboxField({
  helperText,
  innerRef,
  children,
  ...props
}: CheckboxFieldProps) {
  const { field, error } = useTsController<boolean>();
  const { label } = useDescription();

  return (
    <Field
      error={error?.errorMessage}
      htmlFor={props.id}
      helperText={helperText}
    >
      <Checkbox
        ref={field.ref}
        value={field.value ? "on" : "off"}
        onChange={(_) => field.onChange(!Boolean(field.value))}
        onBlur={field.onBlur}
        name={field.name}
        disabled={field.disabled}
        {...props}
      >
        {label ?? children}
      </Checkbox>
    </Field>
  );
}
