import { useDescription, useTsController } from "@ts-react/form";
import { CheckIcon, ChevronsUpDownIcon } from "lucide-react";

import { styled } from "#style/jsx";

import { Field } from "./field";
import { createListCollection, Select } from "./ui/select";
import { useMemo } from "react";

export type SelectFielProps = {
  id?: string;
  helperText?: string;
  items?: Array<{
    label: string;
    value: string;
    disabled?: boolean;
    renderLeftIcon?: () => React.ReactNode;
  }>;
  renderValue?: (
    placeholder: string | undefined,
    value: string | undefined,
  ) => React.ReactNode;
};
export function SelectField({
  id,
  items = [],
  helperText,
  renderValue,
}: SelectFielProps) {
  const { field, error } = useTsController<string>();
  const { label, placeholder } = useDescription();

  const collection = useMemo(() => {
    return createListCollection({ items });
  }, [items]);

  return (
    <Field error={error?.errorMessage} helperText={helperText}>
      <Select.Root
        multiple={false}
        positioning={{ sameWidth: true }}
        width="full"
        collection={collection}
        id={id}
        name={field.name}
        ref={field.ref}
        value={field.value ? [field.value] : []}
        onBlur={field.onBlur}
        onValueChange={({ value }) => field.onChange(value[0])}
        disabled={field.disabled}
      >
        {label && <Select.Label htmlFor={id}>{label}</Select.Label>}

        <Select.Control>
          <Select.Trigger>
            {renderValue?.(placeholder, field.value) ?? (
              <Select.ValueText placeholder={placeholder} />
            )}
            <ChevronsUpDownIcon />
          </Select.Trigger>
        </Select.Control>

        <Select.Positioner>
          <Select.Content>
            <Select.ItemGroup>
              {items?.map((item) => (
                <Select.Item key={item.value} item={item}>
                  <Select.ItemText
                    display="flex"
                    flexDir="row"
                    alignItems="center"
                    gap="2"
                  >
                    {item.renderLeftIcon && (
                      <styled.span display="inline-block" h="4" w="4">
                        {item.renderLeftIcon?.()}
                      </styled.span>
                    )}
                    {item.label}
                  </Select.ItemText>
                  <Select.ItemIndicator>
                    <CheckIcon />
                  </Select.ItemIndicator>
                </Select.Item>
              ))}
            </Select.ItemGroup>
          </Select.Content>
        </Select.Positioner>
      </Select.Root>
    </Field>
  );
}
