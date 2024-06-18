import { batch, createEffect, createSignal } from "solid-js";
import { createAsync, revalidate } from "@solidjs/router";

import { Button } from "#root/components/ui/button";
import { HStack, VStack } from "#style/jsx";
import { IntegrationType } from "#root/lib/integrations/integrations-models";
import {
  openIntegrationWindow,
  getUserIntegrations,
} from "#root/lib/integrations/integrations-services";
import { Heading } from "#root/components/ui/heading";

export default function AppDashboard() {
  const [integrationWindowRef, setIntegrationWindowRef] =
    createSignal<Window | null>(null);
  const [currentIntegrationType, setCurrentIntegrationType] =
    createSignal<IntegrationType | null>(null);
  const integrations = createAsync(() => getUserIntegrations());

  const getPlatformStatus = () => {
    const integrationUnwrapped = integrations();
    const returnObject = {
      [IntegrationType.Spotify]: false,
      [IntegrationType.AppleMusic]: false,
    };

    switch (integrationUnwrapped?.status) {
      case "ok":
        integrationUnwrapped.data.data.forEach((integration) => {
          returnObject[integration.name] = true;
        });

        return returnObject;

      default:
        return returnObject;
    }
  };

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
            revalidate(getUserIntegrations.key);
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
          disabled={
            currentIntegrationType() === IntegrationType.Spotify ||
            getPlatformStatus()[IntegrationType.Spotify]
          }
          onClick={createIntegrationButtonClickedListener(
            IntegrationType.Spotify,
          )}
        >
          {getPlatformStatus()[IntegrationType.Spotify]
            ? "Connected to Spotify"
            : "Connect to Spotify"}
        </Button>

        <Button
          type="button"
          disabled={
            currentIntegrationType() === IntegrationType.AppleMusic ||
            getPlatformStatus()[IntegrationType.AppleMusic]
          }
          onClick={createIntegrationButtonClickedListener(
            IntegrationType.AppleMusic,
          )}
        >
          {getPlatformStatus()[IntegrationType.AppleMusic]
            ? "Connected to Apple Music"
            : "Connect to Apple Music"}
        </Button>
      </HStack>
    </VStack>
  );
}
