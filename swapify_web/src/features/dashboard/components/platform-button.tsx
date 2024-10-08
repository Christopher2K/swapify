import { CircleCheck } from "lucide-react";
import type { ReactNode } from "react";

import { HStack, styled } from "#style/jsx";
import { Text } from "#root/components/ui/text";
import { Button } from "#root/components/ui/button";
import { css } from "#style/css";
import { Spinner } from "#root/components/ui/spinner";

export type PlatformButtonProps = {
  icon: ReactNode;
  label: string;
  onClick: () => void;
  isDone: boolean;
  isLoading: boolean;
  isDisabled?: boolean;
  loadingLabel?: string;
};

export function PlatformButton({
  icon,
  label,
  onClick,
  isDone,
  isDisabled,
  isLoading,
  loadingLabel,
}: PlatformButtonProps) {
  return (
    <Button
      size="lg"
      onClick={onClick}
      disabled={isDone || isDisabled}
      loading={isLoading}
      loadingText={
        isLoading ? (
          <PlatformButtonLoading loadingText={loadingLabel} />
        ) : undefined
      }
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

export type PlatformButtonLoadingProps = {
  loadingText?: string;
};
function PlatformButtonLoading({ loadingText }: PlatformButtonLoadingProps) {
  return (
    <HStack>
      <Spinner />
      {loadingText && <span>{loadingText}</span>}
    </HStack>
  );
}
