import {
  type PropsWithChildren,
  useState,
  useContext,
  useEffect,
  createContext,
} from "react";
import { XIcon, Logs } from "lucide-react";

import { HStack, VStack, Box } from "#style/jsx";

import { Button } from "./ui/button";
import { Text } from "./ui/text";
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
            {children}
          </Box>
        </HStack>
      </VStack>
    </ScreenOptionsContext.Provider>
  );
}

// {/* <HStack */}
// {/*   as="main" */}
// {/*   justifyContent="flex-start" */}
// {/*   alignItems="flex-start" */}
// {/*   w="full" */}
// {/*   gap="0" */}
// {/*   position="relative" */}
// {/* > */}
// {/*   <VStack */}
// {/*     flex="1" */}
// {/*     w="full" */}
// {/*     minH="100svh" */}
// {/*     gap="0" */}
// {/*     pl={[undefined, "300px"]} */}
// {/*     justifyContent="flex-start" */}
// {/*     alignItems="flex-start" */}
// {/*     transition="all" */}
// {/*     transitionTimingFunction="ease-in-out" */}
// {/*     transitionDuration="fast" */}
// {/*   > */}
// {/*     <Box w="full" maxW="1100px" mx="auto"> */}
// {/*       <HStack */}
// {/*         position="sticky" */}
// {/*         top="0" */}
// {/*         w="full" */}
// {/*         gap="4" */}
// {/*         px="4" */}
// {/*         height="16" */}
// {/*         bg="accent.1" */}
// {/*         zIndex="banner" */}
// {/*       > */}
// {/*         <Button */}
// {/*           display={["block", "none"]} */}
// {/*           variant="outline" */}
// {/*           onClick={() => setIsSidebarMobileOpen(true)} */}
// {/*         > */}
// {/*           <Logs /> */}
// {/*         </Button> */}
// {/*         <Heading as="h1" size="2xl"> */}
// {/*           {pageTitle} */}
// {/*         </Heading> */}
// {/*       </HStack> */}
// {/**/}
// {/*       <Box */}
// {/*         position="relative" */}
// {/*         minH="100%" */}
// {/*         flex={1} */}
// {/*         alignItems="stretch" */}
// {/*         width="full" */}
// {/*         bg="accent.1" */}
// {/*       > */}
// {/*         <Box */}
// {/*           position="absolute" */}
// {/*           height="full" */}
// {/*           width="full" */}
// {/*           zIndex="1" */}
// {/*         ></Box> */}
// {/*       </Box> */}
// {/*     </Box> */}
// {/*   </VStack> */}
// {/* </HStack> */}
