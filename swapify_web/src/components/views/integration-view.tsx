import type { ParentProps } from "solid-js";

import * as Card from "#root/components/ui/card";
import {
  IntegrationType,
  integrationNameMap,
} from "#root/lib/integrations/integrations-models";

type IntegrationViewProps = ParentProps<{
  integrationType: IntegrationType;
}>;

function IntegrationView(props: IntegrationViewProps) {
  const serviceName = integrationNameMap[props.integrationType];
  // TODO: Handle scenario when parent window is closed
  // const parentWindow: Window | undefined | null = window.opener;
  // const hasParent = parentWindow != null;
  // const isParentValid = parentWindow?.location.href.startsWith(
  //   import.meta.env.VITE_APP_URL,
  // );

  return (
    <Card.Root width="lg" maxW="full">
      <Card.Header>
        <Card.Title>Connect your {serviceName} account</Card.Title>
        <Card.Description>
          Swapify needs to access your {serviceName} library to transfer music.
        </Card.Description>
      </Card.Header>
      <Card.Body>{props.children}</Card.Body>
    </Card.Root>
  );
}

export default IntegrationView;
