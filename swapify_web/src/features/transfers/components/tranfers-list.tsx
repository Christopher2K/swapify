import { Button } from "#root/components/ui/button";
import { Text } from "#root/components/ui/text";
import type { APITransfer } from "#root/services/api.types";
import { VStack } from "#style/jsx";
import { Link } from "@tanstack/react-router";
import { TransferItem } from "./transfer-item";

type TransfersListProps = {
  transfers?: Array<APITransfer>;
  predicate?: (transfer: APITransfer) => boolean;
  refetchList?: () => Promise<unknown>;
};
export function TransfersList({
  transfers,
  predicate,
  refetchList,
}: TransfersListProps) {
  const displayedTransfers = predicate
    ? transfers?.filter(predicate)
    : transfers;

  if (!displayedTransfers) return null;

  if (displayedTransfers.length === 0) {
    return (
      <VStack width="100%" justifyContent="flex-start" alignItems="flex-start">
        <Text>No transfers has been started yet!</Text>
        <Button asChild>
          <Link to="/app">Go to dashboard</Link>
        </Button>
      </VStack>
    );
  }

  return (
    <VStack width="100%" gap="4" justifyContent="center" alignItems="center">
      {displayedTransfers.map((transfer) => (
        <TransferItem
          key={transfer.id}
          transfer={transfer}
          refetchTransfers={refetchList}
        />
      ))}
    </VStack>
  );
}
