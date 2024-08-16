import { useEffect } from "react";

import { useScreenOptions } from "#root/components/app-screen-layout";

export function IntegrationsPage() {
  const { setPageTitle } = useScreenOptions();

  useEffect(() => {
    setPageTitle("Integrations");
  }, []);

  return <h1>Integrations</h1>;
}
