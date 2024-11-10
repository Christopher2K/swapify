/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_API_URL: string;
  readonly VITE_APP_URL: string;
  readonly VITE_HIGHLIGHT_PROJECT_ID: string;
  readonly VITE_APP_VERSION: boolean;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
