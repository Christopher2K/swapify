import { createTamagui } from "@tamagui/core";
import { config as baseConfig } from "@tamagui/config/v3";

const config = createTamagui(baseConfig);

type AppConfig = typeof config;

declare module "@tamagui/core" {
  interface TamaguiCustomConfig extends AppConfig {}
}

export default config;
