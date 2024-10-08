import { initContract } from "@ts-rest/core";
import { z } from "zod";

const APIResponseTemplate = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    data: dataSchema,
  });
const APISuccessSchema = z.literal("ok");

const APIErrorTemplate = <T extends z.ZodTypeAny>(dataSchema: T) =>
  z.object({
    errors: dataSchema,
  });

const APIFormErrorsSchema = z.object({
  form: z.record(z.string()),
});

const APIPlatformNameSchema = z.enum(["applemusic", "spotify"]);
export type APIPlatformName = z.infer<typeof APIPlatformNameSchema>;

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
  name: APIPlatformNameSchema,
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

const APIPlaylistSyncStatusSchema = z.enum([
  "unsynced",
  "syncing",
  "synced",
  "error",
]);
export type APIPlaylistSyncStatus = z.infer<typeof APIPlaylistSyncStatusSchema>;

const APIPlaylistSchema = z.object({
  id: z.string(),
  name: z.string().optional(),
  platformId: z.string(),
  platformName: APIPlatformNameSchema,
  tracksTotal: z.number().optional(),
  syncStatus: APIPlaylistSyncStatusSchema,
  insertedAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
  userId: z.string(),
});
export type APIPlaylist = z.infer<typeof APIPlaylistSchema>;

export const APIMetaSchema = z.object({
  socketToken: z.string(),
});
export type APIMeta = z.infer<typeof APIMetaSchema>;

export const APIJobStatusSchema = z.enum(["started", "done", "error"]);
export type APIJobStatus = z.infer<typeof APIJobStatusSchema>;

export const APIJobSchema = z.object({
  id: z.string(),
  name: z.string(),
  status: APIJobStatusSchema,
  userId: z.string(),
  insertedAt: z.string().datetime(),
  updatedAt: z.string().datetime(),
});
export type APIJob = z.infer<typeof APIJobSchema>;

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

const APIUpdateAppleMusicUserTokenPayloadSchema = z.object({
  authToken: z.string(),
});

const c = initContract();

export const contract = c.router({
  getMeta: {
    method: "GET",
    path: "/api/meta",
    responses: {
      200: APIResponseTemplate(APIMetaSchema),
    },
  },
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
  updateAppleMusicUserToken: {
    method: "POST",
    path: "/api/integrations/applemusic/callback",
    body: APIUpdateAppleMusicUserTokenPayloadSchema,
    responses: {
      200: APIResponseTemplate(APISuccessSchema),
    },
  },
  searchUserLibraries: {
    method: "GET",
    path: "/api/playlists/library",
    query: z.object({
      platform: z.string().optional(),
      status: z.array(APIPlaylistSyncStatusSchema).optional(),
    }),
    responses: {
      200: APIResponseTemplate(z.array(APIPlaylistSchema)),
    },
    summary: "Search user libraries",
  },
  startSyncPlatformJob: {
    method: "POST",
    path: "/api/playlists/sync-platform/:platformName",
    pathParams: z.object({
      platformName: APIPlatformNameSchema,
    }),
    body: z.undefined(),
    responses: {
      200: APIResponseTemplate(APIJobSchema),
    },
    summary: "Start a platform synchronization job",
  },
  startSyncLibraryJob: {
    method: "POST",
    path: "/api/playlists/sync-library/:platformName",
    pathParams: z.object({
      platformName: APIPlatformNameSchema,
    }),
    body: z.undefined(),
    responses: {
      200: APIResponseTemplate(APIJobSchema),
    },
    summary: "Start a library synchronization job",
  },
});
