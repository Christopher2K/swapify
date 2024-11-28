import { SquareArrowOutUpRightIcon } from "lucide-react";
import type { ReactNode } from "react";

import { ThemedAlert } from "#root/components/themed-alert";
import { Button } from "#root/components/ui/button";
import { Card } from "#root/components/ui/card";
import { Text } from "#root/components/ui/text";
import { css } from "#style/css";

export type IntegrationCardProps = {
  icon: ReactNode;
  title: string;
  description: string;
  onConnectClick: () => void;
  isDisabled?: boolean;
  isConnected?: boolean;
  isLoading?: boolean;
};

export function IntegrationCard({
  icon,
  title,
  description,
  onConnectClick,
  isDisabled,
  isLoading,
  isConnected,
}: IntegrationCardProps) {
  return (
    <Card.Root>
      <Card.Header
        display="flex"
        flexDirection="column"
        justifyContent="center"
        alignItems="center"
        gap="4"
        className={css({
          "& > svg": {
            width: "50px",
            height: "auto",
          },
        })}
      >
        {icon}
        <Card.Title>{title}</Card.Title>
      </Card.Header>
      <Card.Body>
        <Text textAlign="center">{description}</Text>
      </Card.Body>
      <Card.Footer>
        {isConnected ? (
          <ThemedAlert title="Connected" severity="success" />
        ) : (
          <Button
            variant="solid"
            size="sm"
            w="full"
            disabled={isDisabled}
            loading={isLoading}
            onClick={onConnectClick}
          >
            <SquareArrowOutUpRightIcon />
            Connect
          </Button>
        )}
      </Card.Footer>
    </Card.Root>
  );
}
