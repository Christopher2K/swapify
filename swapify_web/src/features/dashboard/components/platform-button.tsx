import type { ReactNode } from "react";

import { styled } from "#style/jsx";
import { Text } from "#root/components/ui/text";
import { Button } from "#root/components/ui/button";

export type PlatformButtonProps = {
  icon: ReactNode;
  label: string;
  onClick: () => void;
  isConnected: boolean;
  isLoading: boolean;
};

export function PlatformButton({
  icon,
  label,
  onClick,
  isConnected,
  isLoading,
}: PlatformButtonProps) {
  return (
    <Button
      size="xl"
      width="100%"
      onClick={onClick}
      disabled={isConnected}
      loading={isLoading}
    >
      <styled.span maxW="30px" width="full" height="auto">
        {icon}
      </styled.span>
      <Text textStyle="md">{label}</Text>
    </Button>
  );
}
