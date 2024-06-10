import { APIEvent } from "@solidjs/start/server";

import { useSession } from "#root/services/session";
import { sendRedirect } from "vinxi/http";

export async function GET(event: APIEvent) {
  const session = await useSession(event.nativeEvent);
  await session.clear();

  return sendRedirect(event.nativeEvent, "/");
}
