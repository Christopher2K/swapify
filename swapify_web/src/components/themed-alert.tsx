import { ReactNode } from "react";
import { cva, type RecipeVariantProps } from "#style/css";
import { CircleXIcon, InfoIcon, CircleCheckIcon } from "lucide-react";

import { Alert } from "./ui/alert";

const rootVariants = cva({
  base: {
    border: "thin",
  },
  variants: {
    severity: {
      error: {
        borderStyle: "solid",
        borderColor: "tomato.10",
        backgroundColor: "tomato.2",
      },
      info: {
        borderStyle: "solid",
        borderColor: "blue.10",
        backgroundColor: "blue.2",
      },
      success: {
        borderStyle: "solid",
        borderColor: "grass.10",
        backgroundColor: "grass.2",
      },
    },
  },
  defaultVariants: {
    severity: "info",
  },
});

const elementVariants = cva({
  base: {},
  variants: {
    severity: {
      error: {
        stroke: "tomato.10",
        color: "tomato.10",
      },
      info: {
        stroke: "blue.10",
        color: "blue.10",
      },
      success: {
        stroke: "grass.10",
        color: "grass.10",
      },
    },
  },
  defaultVariants: {
    severity: "info",
  },
});

const descriptionVariants = cva({
  base: {},
  variants: {
    severity: {
      error: {
        color: "tomato.9",
      },
      info: {
        color: "blue.9",
      },
      success: {
        color: "grass.9",
      },
    },
  },
  defaultVariants: {
    severity: "info",
  },
});

type AlertSeverity = Defined<
  Defined<RecipeVariantProps<typeof rootVariants>>["severity"]
>;

const icons: Record<
  AlertSeverity,
  ({ className }: { className: string }) => ReactNode
> = {
  error: ({ className }) => <CircleXIcon className={className} />,
  info: ({ className }) => <InfoIcon className={className} />,
  success: ({ className }) => <CircleCheckIcon className={className} />,
};

type ThemedAlertProps = {
  title?: string;
  description?: string;
} & RecipeVariantProps<typeof rootVariants>;

export function ThemedAlert({
  title,
  description,
  severity = "info",
}: ThemedAlertProps) {
  return (
    <Alert.Root className={rootVariants({ severity })}>
      <Alert.Icon asChild>
        {icons[severity]({ className: elementVariants({ severity }) })}
      </Alert.Icon>
      <Alert.Content>
        {title && (
          <Alert.Title className={elementVariants({ severity })}>
            {title}
          </Alert.Title>
        )}
        {description && (
          <Alert.Description className={descriptionVariants({ severity })}>
            {description}
          </Alert.Description>
        )}
      </Alert.Content>
    </Alert.Root>
  );
}
