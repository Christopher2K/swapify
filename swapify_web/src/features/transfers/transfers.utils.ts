import type { APITransfer } from "#root/services/api.types";

import type { TransferStatus } from "./transfers.types";

export function getTransferStatus(transfer: APITransfer): TransferStatus {
  if (transfer.matchingStepJob?.status === "canceled") {
    return "canceled";
  }

  if (
    transfer.matchingStepJob?.status === "error" ||
    transfer.transferStepJob?.status === "error"
  ) {
    return "error";
  }

  if (
    transfer.matchingStepJob?.status === "done" &&
    transfer.transferStepJob?.status === "done"
  ) {
    return "done";
  }

  if (
    transfer.matchingStepJob?.status === "done" &&
    !transfer.transferStepJob
  ) {
    return "wait-for-confirmation";
  }

  if (transfer.transferStepJob?.status === "started") {
    return "transfering";
  }

  return "matching";
}

export function isTransferInProgress(transfer: APITransfer) {
  const status = getTransferStatus(transfer);
  return (
    status === "matching" ||
    status === "transfering" ||
    status === "wait-for-confirmation"
  );
}
