import type { PropsWithChildren } from "react";
import { SparklesIcon } from "lucide-react";

import { Text } from "#root/components/ui/text";
import { Button } from "#root/components/ui/button";
import { css } from "#style/css";
import { Box, HStack, type BoxProps } from "#style/jsx";

import { ContentContainer } from "./content-container";

export type PageContainerProps = PropsWithChildren<{}>;

export const PageContainer = ({ children, ...props }: BoxProps) => (
  <Box position="relative" bg="white" {...props}>
    <BetaBanner />
    <Navbar />
    {children}
    <Footer />
  </Box>
);

export const Navbar = () => (
  <ContentContainer bg="transparent" position="sticky" top="0" zIndex="banner">
    <Box
      /* @ts-expect-error */
      as="nav"
      w="full"
      py="4"
    >
      <HStack
        w="full"
        justifyContent="space-between"
        alignItems="center"
        h="14"
        border="thin"
        borderStyle="solid"
        borderColor="border.default"
        borderRadius="2xl"
        px="4"
        backdropFilter="blur(99px)"
      >
        <Button variant="link" size="2xl" color="bronze.11" asChild>
          <a href="/">Swapify</a>
        </Button>

        <HStack>
          <Button asChild>
            <a href="/app/sign-up">Get started</a>
          </Button>
          <Button variant="outline" asChild>
            <a href="/app/sign-in">Login</a>
          </Button>
        </HStack>
      </HStack>
    </Box>
  </ContentContainer>
);

const Footer = () => (
  <ContentContainer bg="white">
    <HStack w="full" py="12" justifyContent="space-between" alignItems="center">
      <Text>© 2024 Swapify. All rights reserved.</Text>
      <HStack>
        <Button variant="link" asChild>
          <a href="/privacy-policy">Privacy policy</a>
        </Button>
        <Button variant="link">
          <a href="/terms-of-service">Terms of service</a>
        </Button>
      </HStack>
    </HStack>
  </ContentContainer>
);

const BetaBanner = () => (
  <Box
    backgroundColor="bronze.12"
    width="full"
    justifyContent="center"
    alignItems="center"
    gap="2"
    px="2"
    py="2"
  >
    <Text color="bronze.fg" size="sm" fontWeight="medium" textAlign="center">
      <SparklesIcon
        className={css({
          stroke: "bronze.fg",
          display: "inline",
          marginRight: "2",
        })}
        size={16}
      />
      Currently in beta - Early access available now!
    </Text>
  </Box>
);
