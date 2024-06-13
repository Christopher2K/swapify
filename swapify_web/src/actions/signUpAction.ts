import { action } from "@solidjs/router";

import { postSignUp } from "#root/services/api.server";
import { getRequestEvent } from "solid-js/web";

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
