// @ts-no-check
import { defineConfig } from "astro/config";
import svgr from "vite-plugin-svgr";
import tsconfigPaths from "vite-tsconfig-paths";

import react from "@astrojs/react";

import node from "@astrojs/node";

// https://astro.build/config
export default defineConfig({
  output: "server",
  integrations: [react()],

  vite: {
    build: {
      sourcemap: true,
    },
    plugins: [
      tsconfigPaths(),
      svgr({
        svgrOptions: {
          exportType: "default",
        },
      }),
    ],
  },

  adapter: node({
    mode: "standalone",
  }),
});