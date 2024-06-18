import { APIEvent } from "@solidjs/start/server";
import { getProxyRequestHeaders, proxyRequest } from "vinxi/http";

import { useSession } from "#root/lib/auth/session";

async function handler(event: APIEvent) {
  const session = await useSession(event.nativeEvent);
  let headers: Record<string, string> = getProxyRequestHeaders(
    event.nativeEvent,
  );
  if (session.data.auth) {
    headers["authorization"] = `Bearer ${session.data.auth.accessToken}`;
  }

  const requestUrl = new URL(event.request.url);
  const targetUrl =
    process.env.VITE_API_URL + requestUrl.pathname + requestUrl.search;

  return proxyRequest(event.nativeEvent, targetUrl, {
    fetchOptions: {
      redirect: "manual",
    },
    headers,
  });
}

export const GET = handler;
export const POST = handler;
export const PUT = handler;
export const DELETE = handler;
