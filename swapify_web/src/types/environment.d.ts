/// <reference types="vite/client" />

type HybridEnv = {
  readonly VITE_API_URL: string;
};

type ServerEnv = HybridEnv & {
  readonly SESSION_SECRET: string;
};

type ClientEnv = HybridEnv & {};

interface ImportMeta {
  readonly env: ClientEnv;
}
