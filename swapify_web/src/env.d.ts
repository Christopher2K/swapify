/// <reference path="../.astro/types.d.ts" />

interface ImportMetaEnv {
  readonly PUBLIC_API_URL: string;
  readonly PUBLIC_APP_URL: string;
  readonly PUBLIC_HIGHLIGHT_PROJECT_ID: string;
  readonly PUBLIC_APP_VERSION: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
