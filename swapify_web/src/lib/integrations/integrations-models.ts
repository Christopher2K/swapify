export enum IntegrationType {
  Spotify = "spotify",
  AppleMusic = "applemusic",
}

export const integrationNameMap: Record<IntegrationType, string> = {
  [IntegrationType.Spotify]: "Spotify",
  [IntegrationType.AppleMusic]: "Apple Music",
};
