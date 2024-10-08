import type { APIPlatformName } from "#root/services/api.types";

export function getPlatformName(platform: APIPlatformName) {
  switch (platform) {
    case "applemusic":
      return "Apple Music";
    case "spotify":
      return "Spotify";
  }
}
