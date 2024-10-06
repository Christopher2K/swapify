import { z } from "zod";

export const OnboardingStepSchema = z.enum(["PLATFORM", "SYNC_LIB", "READY"]);
export type OnboardingStepSchemaType = z.infer<typeof OnboardingStepSchema>;

export function getTitle(value: OnboardingStepSchemaType) {
  switch (value) {
    case "PLATFORM":
      return "Connect your music accounts";
    case "SYNC_LIB":
      return "Synchronize your library";
    case "READY":
      return "You're all set!";
  }
}
