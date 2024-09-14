import { ComponentProps } from "react";

import { APIPlatformName } from "#root/services/api.types";

import AppleMusicIcon from "./icons/apple-music.svg?react";
import SpotifyIcon from "./icons/spotify.svg?react";

export type PlatformLogoProps = ComponentProps<typeof AppleMusicIcon> & {
  platform: APIPlatformName;
};

export function PlatformLogo({ platform, ...props }: PlatformLogoProps) {
  switch (platform) {
    case "spotify":
      return <SpotifyIcon {...props} />;
    case "applemusic":
      return <AppleMusicIcon {...props} />;
  }
}
