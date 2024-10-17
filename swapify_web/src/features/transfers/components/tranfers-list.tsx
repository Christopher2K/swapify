import type { APITransfer } from "#root/services/api.types";
import { VStack } from "#style/jsx";
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
