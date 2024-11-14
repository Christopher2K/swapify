import { CircleCheck } from "lucide-react";
import type { ReactNode } from "react";

import { Button } from "#root/components/ui/button";
import { Spinner } from "#root/components/ui/spinner";
import { Text } from "#root/components/ui/text";
import { css } from "#style/css";
import { HStack, styled } from "#style/jsx";

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
      height="auto"
      py="2"
      variant="outline"
    >
      <styled.span maxW="24px" width="full" height="auto" flexShrink={0}>
        {icon}
      </styled.span>
      <Text textStyle="md" textWrap="wrap">
        {label}
      </Text>
      {isDone && (
        <CircleCheck
          className={css({
            flexShrink: 0,
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
