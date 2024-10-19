import { useState } from "react";

import { Dialog } from "#root/components/ui/dialog";
import { Button } from "#root/components/ui/button";
import { VStack } from "#style/jsx";

import { TransferForm } from "./transfer-form";

export type CreateTransferButtonProps = {};

export function CreateTransferButton() {
  const [isOpen, setIsOpen] = useState(false);

  const handleOpen = () => {
    setIsOpen(true);
  };

  const handleClose = () => {
    setIsOpen(false);
  };

  return (
    <>
      <Button onClick={handleOpen} disabled={isOpen}>
        Start a new transfer
      </Button>

      <Dialog.Root
        open={isOpen}
        onEscapeKeyDown={handleClose}
        onFocusOutside={handleClose}
        onInteractOutside={handleClose}
        unmountOnExit
      >
        <Dialog.Backdrop />
        <Dialog.Positioner w="full">
          <Dialog.Content
            w="full"
            minWidth={["100%", "100%", "400px"]}
            width="fit-content"
          >
            <VStack p="4" w="full">
              <Dialog.Title mb="4">Start a new playlist transfer</Dialog.Title>
              <TransferForm onSuccess={handleClose} />
            </VStack>
          </Dialog.Content>
        </Dialog.Positioner>
      </Dialog.Root>
    </>
  );
}
