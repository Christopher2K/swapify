import { defineConfig } from "@solidjs/start/config";
import tsconfigPaths from "vite-tsconfig-paths";
import devtools from "solid-devtools/vite";

export default defineConfig({
  middleware: "./src/middleware.ts",
  vite: {
    plugins: [devtools(), tsconfigPaths()],
  },
});
