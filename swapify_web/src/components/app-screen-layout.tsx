import {
  type PropsWithChildren,
  useState,
  useContext,
  useEffect,
  createContext,
} from "react";
import { Logs } from "lucide-react";
import { useRouter } from "@tanstack/react-router";

import { HStack, VStack, Box } from "#style/jsx";

import { Button } from "./ui/button";
import { Text } from "./ui/text";
import { Sidebar } from "./sidebar";

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

  const toggleMobileMenu = () => setIsSidebarMobileOpen((isOpen) => !isOpen);

  useEffect(() => {
    router.subscribe("onBeforeNavigate", () => {
      setIsSidebarMobileOpen(false);
    });
  }, [router]);

  return (
    <ScreenOptionsContext.Provider value={{ setPageTitle }}>
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
            <Box maxWidth="1200px" w="full" mx="auto">
              {children}
            </Box>
          </Box>
        </HStack>
      </VStack>
    </ScreenOptionsContext.Provider>
  );
}
