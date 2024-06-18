import { clientOnly } from "@solidjs/start";
import { isServer } from "solid-js/web";

import { IntegrationType } from "#root/services/integration";
import { Button } from "#root/components/ui/button";
import { styled } from "#style/jsx";
import { useSearchParams } from "@solidjs/router";

const IntegrationView = clientOnly(
  () => import("#root/components/views/integrationView"),
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
