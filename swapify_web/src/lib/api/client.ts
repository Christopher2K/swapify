import ky from "ky";

export const clientApiClient = ky.create({
  credentials: "include",
});

export const serverApiClient = ky.create({
  prefixUrl: import.meta.env.VITE_API_URL,
});
