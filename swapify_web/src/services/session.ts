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
  auth?: {
    accessToken: string;
    refreshToken: string;
    userId: string;
  };
};

export async function useSession(event: HTTPEvent) {
  const session = await baseUseSession<SessionData>(event, sessionConfig);
  return session;
}
