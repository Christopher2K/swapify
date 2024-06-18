import { clientOnly } from "@solidjs/start";

import { Button } from "#root/components/ui/button";
import { IntegrationType } from "#root/lib/integrations/integrations-models";
import {
  getAppleMusicLogin,
  postAppleMusicLoginCallback,
} from "#root/lib/integrations/integrations-client-api";
import { initializeMusicKit } from "#root/lib/integrations/music-kit";

const IntegrationView = clientOnly(
  () => import("#root/components/views/integration-view"),
);

export default function AppleMusicIntegration() {
  async function startAppleMusicLogin() {
    const tokenResponse = await getAppleMusicLogin({});
    switch (tokenResponse.status) {
      case "ok":
        const developerToken = tokenResponse.data.data.developerToken;
        await initializeMusicKit(developerToken);
        const musicToken = await MusicKit.getInstance().authorize();
        if (musicToken) {
          const postResult = await postAppleMusicLoginCallback({
            data: { authToken: musicToken },
          });

          switch (postResult.status) {
            case "ok":
              window.opener.postMessage({ result: "success" });
              break;
            case "error":
              window.opener.postMessage({ result: "error" });
              break;
          }
        }
        break;
      case "error":
        window.opener.postMessage({ result: "error" });
        break;
    }

    window.close();
  }

  return (
    <IntegrationView integrationType={IntegrationType.AppleMusic}>
      <Button onClick={startAppleMusicLogin}>Link apple music account</Button>
    </IntegrationView>
  );
}
