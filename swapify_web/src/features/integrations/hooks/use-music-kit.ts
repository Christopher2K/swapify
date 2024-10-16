import { useEffect, useState } from "react";

export function useMusicKit(developerToken?: string) {
  const [musicKitInstance, setMusicKitInstance] = useState<
    MusicKit.MusicKitInstance | undefined
  >();

  useEffect(() => {
    if (!developerToken) return;

    (
      MusicKit.configure({
        developerToken: developerToken,
        app: {
          name: "Swapify",
          version: "1.0.0",
          build: "1",
        },
      }) as unknown as Promise<MusicKit.MusicKitInstance>
    ).then((mk) => {
      setMusicKitInstance(mk);
    });

    return () => {
      setMusicKitInstance(undefined);
    };
  }, [developerToken]);

  return musicKitInstance;
}
