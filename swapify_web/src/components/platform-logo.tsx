import AppleMusicIcon from "./icons/apple-music.svg?react";
import SpotifyIcon from "./icons/spotify.svg?react";

import { APIPlatformName } from "#root/services/api.types";

export type PlatformLogoProps = {
  platform: APIPlatformName;
};

export function PlatformLogo({ platform }: PlatformLogoProps) {
  switch (platform) {
    case "spotify":
      return <SpotifyIcon />;
    case "applemusic":
      return <AppleMusicIcon />;
  }
}
