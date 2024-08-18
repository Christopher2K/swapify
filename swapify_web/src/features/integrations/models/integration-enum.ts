import { z } from "zod";

export const integrationEnumValidator = z.enum(["spotify", "applemusic"]);
export type IntegrationEnum = z.infer<typeof integrationEnumValidator>;
