import { ComponentProps } from "react";

import { APIPlatformName } from "#root/services/api.types";
import { css, cx } from "#style/css";

import AppleMusicIcon from "./icons/apple-music.svg.tsx";
import SpotifyIcon from "./icons/spotify.svg?react";

export type PlatformLogoProps = ComponentProps<typeof AppleMusicIcon> & {
  platform: APIPlatformName;
};

const baseStyle = css({
  width: "100%",
  height: "auto",
});

export function PlatformLogo({
  platform,
  className,
  ...props
}: PlatformLogoProps) {
  const classNameProp = cx(baseStyle, className);

  switch (platform) {
    case "spotify":
      return <SpotifyIcon className={classNameProp} {...props} />;
    case "applemusic":
      return <AppleMusicIcon className={classNameProp} {...props} />;
    default:
      return null;
  }
}
