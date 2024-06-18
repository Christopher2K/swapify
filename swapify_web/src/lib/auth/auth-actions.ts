import { action, redirect } from "@solidjs/router";
import { getRequestEvent } from "solid-js/web";

import { postSignIn, postSignUp } from "./auth-server-api";
import { useSession } from "./session";
import { getCurrentUser } from "./auth-services";

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
      return redirect("/app", { revalidate: getCurrentUser.key });
    case "error":
      return { error: "Incorrect email / password combination" };
  }
}, "signInAction");

export const signUpAction = action(async (formData: FormData) => {
  "use server";
  const request = getRequestEvent();
  if (!request) throw new Error("requestEvent is undefined");

  const email = formData.get("email")?.toString() ?? "";
  const password = formData.get("password")?.toString() ?? "";
  const username = formData.get("username")?.toString() ?? "";

  const data = {
    username,
    email,
    password,
  };

  const result = await postSignUp({ data });

  switch (result.status) {
    case "ok":
      return { status: "success" as const };
    case "error":
      return {
        status: "error" as const,
        message: "Incorrect email / password combination",
      };
  }
}, "signUpAction");

export const signOutAction = action(async () => {
  "use server";
  const request = getRequestEvent();
  if (!request) throw new Error("requestEvent is undefined");

  const session = await useSession(request.nativeEvent);
  await session.clear();

  throw redirect("/", { revalidate: getCurrentUser.key });
}, "signOutAction");
