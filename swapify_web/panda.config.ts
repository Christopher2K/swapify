import { defineConfig } from "@pandacss/dev";
import { createPreset } from "@park-ui/panda-preset";

const parkUIPreset = createPreset({
  additionalColors: ["red"],
});

export default defineConfig({
  preflight: true,
  presets: ["@pandacss/preset-base", parkUIPreset],
  include: ["./src/**/*.{ts,tsx}"],
  jsxFramework: "solid",
  exclude: [],
  outdir: "styled-system",
});
