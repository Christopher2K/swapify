"use server";
import {
  type SessionConfig,
  type HTTPEvent,
  useSession as baseUseSession,
} from "vinxi/http";

const sessionConfig: SessionConfig = {
  password: process.env.SESSION_SECRET,
  maxAge: 3600,
  name: "swapify",
};

type SessionData = {
  accessToken: string;
  refreshToken: string;
  userId: string;
};

export function useSession(event: HTTPEvent) {
  return baseUseSession<SessionData>(event, sessionConfig);
}
