import { useRouter } from "@tanstack/react-router";
import { Logs } from "lucide-react";
import { type PropsWithChildren, useEffect, useState } from "react";

import { JobUpdateContextProvider } from "#root/features/job/components/job-update-context";
import { Box, HStack, VStack } from "#style/jsx";

import { Sidebar } from "./sidebar";
import { Button } from "./ui/button";
import { Text } from "./ui/text";

type AppScreenLayoutProps = PropsWithChildren;

export function AppScreenLayout({ children }: AppScreenLayoutProps) {
  const [isSidebarMobileOpen, setIsSidebarMobileOpen] = useState(false);
  const router = useRouter();

  const toggleMobileMenu = () => setIsSidebarMobileOpen((isOpen) => !isOpen);

  useEffect(() => {
    router.subscribe("onBeforeNavigate", () => {
      setIsSidebarMobileOpen(false);
    });
  }, [router]);

  return (
    <JobUpdateContextProvider>
      {/* @ts-expect-error */}
      <VStack height="100svh" width="full" as="main" gap="0">
        <HStack
          /* @ts-expect-error */
          as="nav"
          h="64px"
          w="full"
          px="4"
          justifyContent="space-between"
          borderBottom="thin"
          borderStyle="solid"
          borderColor="accent.4"
        >
          <Text textStyle="xl" fontWeight="bold">
            Swapify
          </Text>

          <Button
            display={["block", "none"]}
            variant="outline"
            onClick={toggleMobileMenu}
          >
            <Logs />
          </Button>
        </HStack>
        <HStack width="100%" position="relative" flex={1} gap="0" height="100%">
          <Sidebar
            navProps={{ flexShrink: "0" }}
            isMobileOpen={isSidebarMobileOpen}
          />
          <Box
            position="absolute"
            top="0"
            left={["0", "300px"]}
            right="0"
            height="100%"
            overflow="auto"
          >
            <Box maxWidth="1100px" w="full" mx="auto">
              {children}
            </Box>
          </Box>
        </HStack>
      </VStack>
    </JobUpdateContextProvider>
  );
}
