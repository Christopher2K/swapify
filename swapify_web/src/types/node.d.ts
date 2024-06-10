declare global {
  namespace NodeJS {
    interface ProcessEnv extends ServerEnv {
      ENV?: "test" | "dev" | "prod";
    }
  }
}

export {};
