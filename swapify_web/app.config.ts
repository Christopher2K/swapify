import { defineConfig } from "@solidjs/start/config";
import tsconfigPaths from "vite-tsconfig-paths";

export default defineConfig({
  middleware: "./src/middleware.ts",
  vite: {
    plugins: [tsconfigPaths()],
  },
});
