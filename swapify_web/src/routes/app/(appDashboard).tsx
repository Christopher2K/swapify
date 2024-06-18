import { batch, createEffect, createSignal } from "solid-js";

import { Button } from "#root/components/ui/button";
import { HStack, VStack } from "#style/jsx";
import { IntegrationType } from "#root/lib/integrations/integrations-models";
import { openIntegrationWindow } from "#root/lib/integrations/integrations-services";
import { Heading } from "#root/components/ui/heading";

export default function AppDashboard() {
  const [integrationWindowRef, setIntegrationWindowRef] =
    createSignal<Window | null>(null);
  const [currentIntegrationType, setCurrentIntegrationType] =
    createSignal<IntegrationType | null>(null);

  function createIntegrationButtonClickedListener(
    integrationType: IntegrationType,
  ) {
    return () => {
      const popup = openIntegrationWindow(integrationType);

      batch(() => {
        setCurrentIntegrationType(integrationType);
        setIntegrationWindowRef(popup);
      });
    };
  }

  createEffect(() => {
    const popup = integrationWindowRef();

    if (popup) {
      // TODO: Handle the event closing window
      window.addEventListener("message", (event) => {
        if (event.data.result === "success") {
          console.log("success");
        } else if (event.data.result === "error") {
          console.log("error");
        }
      });

      const intervalRef = setInterval(() => {
        if (popup.closed) {
          clearInterval(intervalRef);
          batch(() => {
            setCurrentIntegrationType(null);
            setIntegrationWindowRef(null);
          });
        }
      }, 1000);
    }
  });

  return (
    <VStack justifyContent="start" alignItems="start">
      <Heading as="h3">Integrations</Heading>
      <HStack>
        <Button
          type="button"
          disabled={currentIntegrationType() === IntegrationType.Spotify}
          onClick={createIntegrationButtonClickedListener(
            IntegrationType.Spotify,
          )}
        >
          Spotify
        </Button>

        <Button
          type="button"
          disabled={currentIntegrationType() === IntegrationType.AppleMusic}
          onClick={createIntegrationButtonClickedListener(
            IntegrationType.AppleMusic,
          )}
        >
          Apple Music
        </Button>
      </HStack>
    </VStack>
  );
}
