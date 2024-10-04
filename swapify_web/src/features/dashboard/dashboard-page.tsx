import { useEffect } from "react";

import { useScreenOptions } from "#root/components/app-screen-layout";
import { VStack } from "#style/jsx";

export function DashboardPage() {
  const { setPageTitle } = useScreenOptions();

  useEffect(() => {
    setPageTitle("Dashboard");
  }, []);

  return (
    <VStack
      w="full"
      h="full"
      p="4"
      gap="10"
      justifyContent="flex-start"
      alignItems="flex-start"
    ></VStack>
  );
}
