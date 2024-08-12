import { defineConfig } from "vite";
import tsconfigPaths from "vite-tsconfig-paths";
import react from "@vitejs/plugin-react";

export default defineConfig({
  clearScreen: true,
  plugins: [tsconfigPaths(), react()],
});
