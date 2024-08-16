import { useEffect } from "react";

import { useScreenOptions } from "#root/components/app-screen-layout";

export function DashboardPage() {
  const { setPageTitle } = useScreenOptions();

  useEffect(() => {
    setPageTitle("Dashboard");
  }, []);

  return <h1>Dashboard</h1>;
}
