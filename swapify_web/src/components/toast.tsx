import { createToaster, Toaster } from "@ark-ui/react/toast";
import { XIcon } from "lucide-react";

import { IconButton } from "#root/components/ui/icon-button";
import { Toast } from "#root/components/ui/toast";

import { cva } from "#style/css";

export const toaster = createToaster({
  placement: "top",
  overlap: true,
  gap: 16,
  duration: 10000,
});

const rootStyle = cva({
  base: {},
  variants: {
    type: {
      error: {
        backgroundColor: "red.4",
      },
      success: {
        backgroundColor: "green.4",
      },
      info: {},
      loading: {},
    },
  },
});

const textStyle = cva({
  base: {},
  variants: {
    type: {
      error: {
        color: "red.9",
      },
      success: {
        color: "green.9",
      },
      info: {},
      loading: {},
    },
  },
});

const iconStyle = cva({
  base: {},
  variants: {
    type: {
      error: {
        stroke: "red.9",
      },
      success: {
        stroke: "green.9",
      },
      info: {},
      loading: {},
    },
  },
});

export function ToastRoot() {
  return (
    <Toaster toaster={toaster}>
      {(toast) => (
        // @ts-expect-error
        <Toast.Root className={rootStyle({ type: toast.type })}>
          {/* @ts-expect-error */}
          <Toast.Title className={textStyle({ type: toast.type })}>
            {toast.title}
          </Toast.Title>

          {/* @ts-expect-error */}
          <Toast.Description className={textStyle({ type: toast.type })}>
            {toast.description}
          </Toast.Description>
          <Toast.CloseTrigger asChild>
            <IconButton size="sm" variant="link">
              {/* @ts-expect-error */}
              <XIcon className={iconStyle({ type: toast.type })} />
            </IconButton>
          </Toast.CloseTrigger>
        </Toast.Root>
      )}
    </Toaster>
  );
}
