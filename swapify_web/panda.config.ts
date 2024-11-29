import { defineConfig } from "@pandacss/dev";
import { createPreset } from "@park-ui/panda-preset";
import neutral from "@park-ui/panda-preset/colors/neutral";
import bronze from "@park-ui/panda-preset/colors/bronze";

const parkUIPreset = createPreset({
  accentColor: bronze,
  grayColor: neutral,
  radius: "md",
});

export default defineConfig({
  preflight: true,
  presets: ["@pandacss/preset-base", parkUIPreset],
  jsxFramework: "react",
  include: ["./src/**/*.{ts,tsx,astro}"],
  exclude: [],
  outdir: "styled-system",
  globalFontface: {
    Outfit: {
      src: [
        'url("/fonts/Outfit-VariableFont.woff2") format("woff2-variations")',
        'url("/fonts/Outfit-VariableFont.woff2") format("woff2") tech("variations")',
      ],
      fontWeight: "100 900",
      fontDisplay: "swap",
    },
  },
  globalVars: {
    "--font-outfit": "Outfit, ui-sans-serif",
    "--global-font-body": "var(--font-outfit)",
  },
  globalCss: {
    "#root": {
      width: "full",
      minHeight: "100vh",
    },
  },
  theme: {
    extend: {
      slotRecipes: {
        card: {
          base: {
            root: {
              boxShadow: "sm",
            },
          },
        },
        checkbox: {
          base: {
            control: {
              flexShrink: "0",
            },
          },
        },
      },
    },
  },
});
