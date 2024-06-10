import { createMiddleware } from "@solidjs/start/middleware";

export default createMiddleware({
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
