import { createProxyEventHandler } from "h3-proxy";
import { APIEvent } from "@solidjs/start/server";

import { useSession } from "#root/services/session";

const proxy = createProxyEventHandler({
  target: import.meta.env.VITE_API_URL,
  enableLogger: true,
  configureProxyRequest(event) {
    const mbToken = event.context["accessToken"];
    if (mbToken) {
      return {
        headers: {
          Authorization: "Bearer " + mbToken,
        },
      };
    }
    return {};
  },
});

async function handler(event: APIEvent) {
  const session = await useSession(event.nativeEvent);
  if (session.data.auth) {
    event.nativeEvent.context["accessToken"] = session.data.auth.accessToken;
  }

  return proxy(event.nativeEvent);
}

export const GET = handler;
export const POST = handler;
export const PUT = handler;
export const DELETE = handler;
