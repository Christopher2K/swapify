/**
 * This is supposed to to be open in a popup
 */
import { useMemo } from "react";
import { useParams } from "@tanstack/react-router";

import { Text } from "#root/components/ui/text";
import { Heading } from "#root/components/ui/heading";
import { integrationEnumValidator } from "#root/features/integrations/models/integration-enum";
import { AppleMusicConfigurationPage } from "#root/features/integrations/components/apple-music-configuration";

function SpotifyConfigurationPage() {
  return (
    <div>
      <Heading>Spotify Configuration</Heading>
      <Text>This is the Spotify configuration page</Text>
    </div>
  );
}

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
    return <AppleMusicConfigurationPage />;
  }

  if (integrationName === "spotify") {
    return <SpotifyConfigurationPage />;
  }
}
