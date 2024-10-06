import { CircleCheck } from "lucide-react";
import type { ReactNode } from "react";

import { styled } from "#style/jsx";
import { Text } from "#root/components/ui/text";
import { Button } from "#root/components/ui/button";
import { css } from "#style/css";

export type PlatformButtonProps = {
  icon: ReactNode;
  label: string;
  onClick: () => void;
  isDone: boolean;
  isLoading: boolean;
};

export function PlatformButton({
  icon,
  label,
  onClick,
  isDone,
  isLoading,
}: PlatformButtonProps) {
  return (
    <Button
      size="lg"
      onClick={onClick}
      disabled={isDone}
      loading={isLoading}
      variant="outline"
    >
      <styled.span maxW="24px" width="full" height="auto" flexShrink={0}>
        {icon}
      </styled.span>
      <Text textStyle="md">{label}</Text>
      {isDone && (
        <CircleCheck
          className={css({
            stroke: "green",
          })}
        />
      )}
    </Button>
  );
}
