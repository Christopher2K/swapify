/**
 * This is supposed to to be open in a popup
 */
import { useMemo } from "react";
import { useParams } from "@tanstack/react-router";

import { integrationEnumValidator } from "#root/features/integrations/models/integration-enum";
import { SpotifyConfiguration } from "#root/features/integrations/components/spotify-configuration";
import { AppleMusicConfiguration } from "#root/features/integrations/components/apple-music-configuration";

export function IntegrationConfigurationPage() {
  const params = useParams({
    from: "/authenticated/integrations/$integrationName",
  });

  const integrationName = useMemo(() => {
    try {
      return integrationEnumValidator.parse(params.integrationName);
    } catch (error) {
      return null;
    }
  }, [params.integrationName]);

  if (window.opener == null) {
    return <h1>Error</h1>;
  }

  if (integrationName == null) {
    window.close();
    return null;
  }

  if (integrationName === "applemusic") {
    return <AppleMusicConfiguration />;
  }

  if (integrationName === "spotify") {
    return <SpotifyConfiguration />;
  }
}
