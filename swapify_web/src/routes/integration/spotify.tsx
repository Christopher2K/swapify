import { clientOnly } from "@solidjs/start";
import { isServer } from "solid-js/web";
import { useSearchParams } from "@solidjs/router";

import { IntegrationType } from "#root/lib/integrations/integrations-models";
import { Button } from "#root/components/ui/button";
import { styled } from "#style/jsx";

const IntegrationView = clientOnly(
  () => import("#root/components/views/integration-view"),
);

type SearchParams = {
  result?: "success" | "error";
};

export default function SpotifyIntegration() {
  const [params] = useSearchParams<SearchParams>();

  if (!isServer && params.result) {
    window.postMessage({ result: params.result });
    window.close();
  }

  return (
    <IntegrationView integrationType={IntegrationType.Spotify}>
      <styled.form
        method="get"
        action="/api/integrations/spotify/login"
        w="full"
      >
        <Button type="submit">Connect Spotify account</Button>
      </styled.form>
    </IntegrationView>
  );
}
