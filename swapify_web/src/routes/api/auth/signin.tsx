import { APIEvent } from "@solidjs/start/server";

import { type SignInData, postSignIn } from "#root/services/api";
import { useSession } from "#root/services/session";

export async function POST(event: APIEvent) {
  const data = (await event.request.json()) as SignInData;
  const result = await postSignIn({ data });
  const session = await useSession(event.nativeEvent);

  switch (result.status) {
    case "ok":
      const response = result.data.data;
      await session.update({
        auth: {
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          userId: response.user.id,
        },
      });
      return response.user;
    case "error":
      const json = JSON.stringify(result.data ?? { error: "unauthorized" });

      return new Response(json, {
        status: result.code ?? 401,
        headers: {
          "Content-Type": "application/json",
        },
      });
  }
}
