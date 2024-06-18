/// <reference types="vite/client" />

type HybridEnv = {
  readonly VITE_API_URL: string;
  readonly VITE_APP_URL: string;
};

type ServerEnv = HybridEnv & {
  readonly SESSION_SECRET: string;
};

type ClientEnv = HybridEnv & {};

interface ImportMeta {
  readonly env: ClientEnv;
}
