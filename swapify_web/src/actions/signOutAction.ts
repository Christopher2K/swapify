import { action, redirect } from "@solidjs/router";
import { getRequestEvent } from "solid-js/web";

import { getUser } from "#root/services/auth";
import { useSession } from "#root/services/session";

export const signOutAction = action(async () => {
  "use server";

  const request = getRequestEvent();
  if (!request) throw new Error("requestEvent is undefined");

  const session = await useSession(request.nativeEvent);
  await session.clear();

  throw redirect("/", { revalidate: getUser.key });
}, "signOutAction");
