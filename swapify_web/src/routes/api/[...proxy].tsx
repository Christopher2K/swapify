import { createProxyEventHandler } from "h3-proxy";
import { APIEvent } from "@solidjs/start/server";

const proxy = createProxyEventHandler({
  target: import.meta.env.VITE_API_URL,
  enableLogger: true,
});

function handler(event: APIEvent) {
  return proxy(event.nativeEvent);
}

export const GET = handler;
export const POST = handler;
export const PUT = handler;
export const DELETE = handler;
