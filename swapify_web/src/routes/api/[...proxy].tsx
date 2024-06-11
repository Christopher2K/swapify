import { APIEvent } from "@solidjs/start/server";
import { sendProxy } from "vinxi/http";

import { useSession } from "#root/services/session";

async function handler(event: APIEvent) {
  const session = await useSession(event.nativeEvent);
  let headers: Record<string, string> = {};
  if (session.data.auth) {
    headers["Authorization"] = `Bearer ${session.data.auth.accessToken}`;
  }

  return sendProxy(
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
