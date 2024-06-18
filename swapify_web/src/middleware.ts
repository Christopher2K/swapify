import { createMiddleware } from "@solidjs/start/middleware";

import { useSession } from "#root/lib/auth/session";

export default createMiddleware({
  onRequest: [
    async ({ nativeEvent }) => {
      const session = await useSession(nativeEvent);
      console.log(
        `Session: ${session.id} - User: ${session.data.auth?.userId || `null`}`,
      );
    },
  ],
  onBeforeResponse: [
    // LOGGER
    async ({ nativeEvent: event }) => {
      const method = event.method || "-";
      const path = event.path || "-";
      const httpVersion = event.node.req.httpVersion;
      const statusCode = event.node.res.statusCode || "-";

      console.log(`${method} ${path} HTTP/${httpVersion}" ${statusCode}`);
    },
  ],
});
