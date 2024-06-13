import { action, redirect } from "@solidjs/router";

import { postSignIn } from "#root/services/api.server";
import { useSession } from "#root/services/session";
import { getRequestEvent } from "solid-js/web";
import { getUser } from "#root/services/auth";

export const signInAction = action(async (formData: FormData) => {
  "use server";
  const request = getRequestEvent();
  if (!request) throw new Error("requestEvent is undefined");

  const email = formData.get("email")?.toString() ?? "";
  const password = formData.get("password")?.toString() ?? "";
  const data = {
    email,
    password,
  };

  const result = await postSignIn({ data });
  const session = await useSession(request.nativeEvent);

  switch (result.status) {
    case "ok":
      const response = result.data.data;
      await session.update({
        auth: {
          username: response.user.username,
          accessToken: response.accessToken,
          refreshToken: response.refreshToken,
          userId: response.user.id,
        },
      });
      return redirect("/app", { revalidate: getUser.key });
    case "error":
      return { error: "Incorrect email / password combination" };
  }
}, "signInAction");
