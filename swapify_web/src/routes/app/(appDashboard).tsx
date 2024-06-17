import { Button } from "#root/components/ui/button";
import {
  getAppleMusicLogin,
  postAppleMusicLoginCallback,
} from "#root/services/api.client";
import { initializeMusicKit } from "#root/services/musicKit";

export default function AppDashboard() {
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
            // Show a success
            case "error":
            // Show an error
          }
        }
      case "error":
      // Do something
    }
  }

  return (
    <>
      <form method="get" action="/api/integrations/spotify/login">
        <Button type="submit">Link spotify account</Button>
      </form>

      <Button onClick={startAppleMusicLogin}>Link apple music account</Button>
    </>
  );
}
