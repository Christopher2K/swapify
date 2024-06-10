import httpProxy from "http-proxy";
import { APIEvent } from "@solidjs/start/server";

const proxy = httpProxy.createProxy();

/**
 * Proxy EVERYTHING to the API
 */
function handler(event: APIEvent) {
  return new Promise((resolve, reject) => {
    proxy.web(
      event.nativeEvent.node.req,
      event.nativeEvent.node.res,
      {
        target: import.meta.env.VITE_API_URL,
        changeOrigin: true,
      },
      (err, _req, response) => {
        if (err) {
          return reject(err);
        }
        resolve(response);
      },
    );
  });
}

export const GET = handler;
export const POST = handler;
export const PUT = handler;
export const DELETE = handler;
