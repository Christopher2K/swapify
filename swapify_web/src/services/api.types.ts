import { initContract } from "@ts-rest/core";
import { z } from "zod";

const APIResponseTemplate = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    data: dataSchema,
  });

const APIErrorTemplate = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    errors: dataSchema,
  });

const APIFormErrorsSchema = z.object({
  form: z.record(z.string()),
});

const APIUserSchema = z.object({
  id: z.string(),
  username: z.string(),
  email: z.string(),
  insertedAt: z.string(),
  updatedAt: z.string(),
});
export type APIUser = z.infer<typeof APIUserSchema>;

const APIPlatformConnectionSchema = z.object({
  id: z.string(),
  name: z.string(),
  accessTokenExp: z.string(),
  userId: z.string(),
});
export type APIPlatformConnection = z.infer<typeof APIPlatformConnectionSchema>;

const APITrackSchema = z.object({
  isrc: z.string().optional(),
  name: z.string(),
  artists: z.array(z.string()),
  album: z.string(),
});
export type APITrack = z.infer<typeof APITrackSchema>;

const APIPlaylistSchema = z.object({
  id: z.string(),
  name: z.string().optional(),
  platformName: z.string(),
  isLibrary: z.boolean(),
  tracks: z.array(APITrackSchema),
});
export type APIPlaylist = z.infer<typeof APIPlaylistSchema>;

// API Payloads
const APISignupPayloadSchema = z.object({
  username: z.string(),
  email: z.string(),
  password: z.string(),
});
export type APISignupPayload = z.infer<typeof APISignupPayloadSchema>;

const APISigninPayloadSchema = z.object({
  email: z.string(),
  password: z.string(),
});
export type APISigninPayload = z.infer<typeof APISigninPayloadSchema>;

const c = initContract();

export const contract = c.router({
  getUser: {
    method: "GET",
    path: "/api/users/me",
    responses: {
      200: APIResponseTemplate(APIUserSchema),
    },
    summary: "Get the current user",
  },
  signupUser: {
    method: "POST",
    path: "/api/auth/signup",
    body: APISignupPayloadSchema,
    responses: {
      200: APIResponseTemplate(APIUserSchema),
      422: APIErrorTemplate(APIFormErrorsSchema),
    },
    summary: "Sign up a new user",
  },
  signinUser: {
    method: "POST",
    path: "/api/auth/signin",
    body: APISigninPayloadSchema,
    responses: {
      200: APIResponseTemplate(APIUserSchema),
    },
    summary: "Sign in a user",
  },
  getIntegrations: {
    method: "GET",
    path: "/api/integrations",
    responses: {
      200: APIResponseTemplate(z.array(APIPlatformConnectionSchema)),
    },
    summary: "Get the integrations of the current user",
  },
  getAppleMusicDeveloperToken: {
    method: "GET",
    path: "/api/integrations/applemusic/login",
    responses: {
      200: APIResponseTemplate(
        z.object({
          developerToken: z.string(),
        }),
      ),
    },
    summary: "Get the Apple Music Developer Token",
  },
  getUserLibraries: {
    method: "GET",
    path: "/api/playlists/library",
    query: z.object({
      platform: z.string().optional(),
    }),
    responses: {
      200: APIResponseTemplate(z.array(APIPlaylistSchema)),
    },
    summary: "Get the user libraries",
  },
});
