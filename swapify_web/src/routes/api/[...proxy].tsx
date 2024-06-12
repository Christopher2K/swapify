import { APIEvent } from "@solidjs/start/server";
import { getProxyRequestHeaders, proxyRequest } from "vinxi/http";

import { useSession } from "#root/services/session";

async function handler(event: APIEvent) {
  const session = await useSession(event.nativeEvent);
  let headers: Record<string, string> = getProxyRequestHeaders(
    event.nativeEvent,
  );
  if (session.data.auth) {
    headers["authorization"] = `Bearer ${session.data.auth.accessToken}`;
  }

  return proxyRequest(
    event.nativeEvent,
    process.env.VITE_API_URL + new URL(event.request.url).pathname,
    {
      fetchOptions: {
        redirect: "manual",
      },
      headers,
    },
  );
}

export const GET = handler;
export const POST = handler;
export const PUT = handler;
export const DELETE = handler;
