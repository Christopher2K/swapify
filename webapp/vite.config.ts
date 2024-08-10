import { defineConfig } from "vite";
import tsconfigPaths from "vite-tsconfig-paths";
import react from "@vitejs/plugin-react";
import { tamaguiExtractPlugin, tamaguiPlugin } from "@tamagui/vite-plugin";

const shouldExtract = process.env.EXTRACT === "1";

const tamaguiConfig = {
  components: ["tamagui"],
  config: "src/tamagui.config.ts",
};

export default defineConfig({
  clearScreen: true,
  plugins: [
    tsconfigPaths(),
    react(),
    tamaguiPlugin(tamaguiConfig),
    shouldExtract ? tamaguiExtractPlugin(tamaguiConfig) : null,
  ].filter(Boolean),
});
