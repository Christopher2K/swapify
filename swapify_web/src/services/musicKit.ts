export function initializeMusicKit(token: string) {
  return MusicKit.configure({
    developerToken: token,
    app: {
      name: "Swapify",
      build: "1.0.0",
    },
  });
}
