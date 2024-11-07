import { toaster } from "#root/components/toast";
import { isErrorResponse } from "@ts-rest/core";

const DEFAULT_ERROR_MESSAGE = "An error occurred. Please try again.";

export function handleApiError(error: unknown) {
  if (isErrorResponse(error)) {
    if (error.status !== 422) {
      toaster.create({
        type: "error",
        description: error.body?.message ?? DEFAULT_ERROR_MESSAGE,
      });
    }
  } else {
    toaster.create({
      type: "error",
      description: "An error occurred. Please reload the page.",
    });
  }
}
