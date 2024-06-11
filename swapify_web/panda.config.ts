import { defineConfig } from "@pandacss/dev";

export default defineConfig({
  preflight: true,
  include: ["./src/**/*.{ts,tsx}"],
  jsxFramework: "solid",
  exclude: [],
  theme: {
    extend: {},
  },
  outdir: "styled-system",
});
