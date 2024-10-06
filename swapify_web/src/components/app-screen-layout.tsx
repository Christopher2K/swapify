import {
  type PropsWithChildren,
  useState,
  useContext,
  useEffect,
  createContext,
} from "react";
import { Logs } from "lucide-react";

import { HStack, VStack, Box } from "#style/jsx";

import { Button } from "./ui/button";
import { Sidebar } from "./sidebar";
import { Heading } from "./ui/heading";
import { useRouter } from "@tanstack/react-router";

type ScreenOptionsContextType = {
  setPageTitle: (title: string) => void;
};

const ScreenOptionsContext = createContext<ScreenOptionsContextType>({
  setPageTitle: () => {},
});

export function useScreenOptions() {
  return useContext(ScreenOptionsContext);
}

type AppScreenLayoutProps = PropsWithChildren;

export function AppScreenLayout({ children }: AppScreenLayoutProps) {
  const [isSidebarMobileOpen, setIsSidebarMobileOpen] = useState(false);
  const [pageTitle, setPageTitle] = useState("");
  const router = useRouter();

  useEffect(() => {
    router.subscribe("onBeforeNavigate", () => {
      setIsSidebarMobileOpen(false);
    });
  }, [router]);

  return (
    <ScreenOptionsContext.Provider value={{ setPageTitle }}>
      <HStack
        /* @ts-expect-error */
        as="main"
        justifyContent="flex-start"
        alignItems="flex-start"
        w="full"
        gap="0"
        position="relative"
      >
        <Sidebar
          navProps={{ flexShrink: "0" }}
          isMobileOpen={isSidebarMobileOpen}
          onMobileClose={() => setIsSidebarMobileOpen(false)}
        />
        <VStack
          flex="1"
          w="full"
          minH="100svh"
          gap="0"
          pl={[undefined, "300px"]}
          justifyContent="flex-start"
          alignItems="flex-start"
          transition="all"
          transitionTimingFunction="ease-in-out"
          transitionDuration="fast"
        >
          <Box w="full" maxW="1100px" mx="auto">
            <HStack
              position="sticky"
              top="0"
              w="full"
              gap="4"
              px="4"
              height="16"
              bg="accent.1"
              zIndex="banner"
            >
              <Button
                display={["block", "none"]}
                variant="outline"
                onClick={() => setIsSidebarMobileOpen(true)}
              >
                <Logs />
              </Button>
              <Heading as="h1" size="2xl">
                {pageTitle}
              </Heading>
            </HStack>

            <Box
              position="relative"
              minH="100%"
              flex={1}
              alignItems="stretch"
              width="full"
              bg="accent.1"
            >
              <Box position="absolute" height="full" width="full" zIndex="1">
                {children}
              </Box>
            </Box>
          </Box>
        </VStack>
      </HStack>
    </ScreenOptionsContext.Provider>
  );
}
