import { defineConfig } from "@pandacss/dev";
import { createPreset } from "@park-ui/panda-preset";
import neutral from "@park-ui/panda-preset/colors/neutral";

const parkUIPreset = createPreset({
  accentColor: neutral,
  grayColor: neutral,
  radius: "2xl",
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
