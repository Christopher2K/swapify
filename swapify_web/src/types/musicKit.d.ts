type MusicKitInstance = {
  authorize(): Promise<string | undefined>;
};

type MusicKitType = {
  configure(args: {
    developerToken: string;
    app: {
      name: string;
      build: string;
    };
  }): Promise<unknown>;
  getInstance(): MusicKitInstance;
};

declare const MusicKit: MusicKitType;
