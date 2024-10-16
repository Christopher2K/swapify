import { defineConfig } from "@pandacss/dev";
import { createPreset } from "@park-ui/panda-preset";

const parkUIPreset = createPreset({
  additionalColors: ["red", "tomato", "blue", "grass", "amber"],
});

export default defineConfig({
  preflight: true,
  presets: ["@pandacss/preset-base", parkUIPreset],
  jsxFramework: "react",
  include: ["./src/**/*.{ts,tsx}"],
  exclude: [],
  outdir: "styled-system",
  theme: {
    extend: {},
  },
});
