import { QueryClient } from "@tanstack/react-query";
import { initTsrReactQuery } from "@ts-rest/react-query/v5";

import { contract } from "./api.types";

export const queryClient = new QueryClient({
  defaultOptions: {
    queries: {
      refetchOnWindowFocus: false,
    },
  },
});

export const tsr = initTsrReactQuery(contract, {
  baseUrl: import.meta.env.VITE_API_URL,
  baseHeaders: {
    "x-swapify-application": "swapify-web",
    accept: "application/json",
    "content-type": "application/json",
  },
  credentials: "include",
});

export function getApiUrl(path: `/${string}`) {
  return import.meta.env.VITE_API_URL + path;
}
