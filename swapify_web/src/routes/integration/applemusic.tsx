import { clientOnly } from "@solidjs/start";

import { Button } from "#root/components/ui/button";
import { IntegrationType } from "#root/services/integration";
import {
  getAppleMusicLogin,
  postAppleMusicLoginCallback,
} from "#root/services/api.client";
import { initializeMusicKit } from "#root/services/musicKit";

const IntegrationView = clientOnly(
  () => import("#root/components/views/integrationView"),
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
