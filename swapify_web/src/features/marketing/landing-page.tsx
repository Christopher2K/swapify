import {
  SparklesIcon,
  ArrowRightIcon,
  Music2Icon,
  RefreshCwIcon,
  SwatchBookIcon,
} from "lucide-react";
import type { ReactNode } from "@tanstack/react-router";

import { Text } from "#root/components/ui/text";
import { VStack, HStack, Box, Stack } from "#style/jsx";
import { css } from "#style/css";
import { Heading } from "#root/components/ui/heading";
import { Button } from "#root/components/ui/button";
import { Card } from "#root/components/ui/card";
import { PlatformLogo } from "#root/components/platform-logo";

import { ContentContainer } from "./components/content-container";

const Hero = () => (
  <ContentContainer bg="white">
    <VStack
      w="full"
      gap="0"
      justifyContent="flex-start"
      alignItems="flex-start"
    >
      <VStack
        w="full"
        gap="0"
        justifyContent="flex-start"
        alignItems="flex-start"
        py={["12", undefined, "24"]}
        flex="1"
      >
        <Heading
          as="h1"
          size={["4xl", null, "5xl", "7xl"]}
          textAlign={["center", null, "left"]}
          fontWeight="medium"
          mb="10"
          color="bronze.12"
        >
          <Text as="span" textWrap="balance" display="block">
            Focus on listening
          </Text>
          <Text as="span" textWrap="balance" display="block">
            We're making your music available everywhere
          </Text>
        </Heading>

        <Heading
          as="h2"
          size={["xl", null, "2xl"]}
          textAlign={["center", null, "left"]}
          textWrap="balance"
          fontWeight="medium"
          color="neutral.11"
          mb="10"
          w="full"
        >
          <Text as="span" textWrap="balance" display="block">
            With Swapify, transfer your music library between different
            platforms.
          </Text>
          <Text as="span" textWrap="balance" display="block">
            Take control of your musical journey.
          </Text>
        </Heading>

        <Button size="xl" asChild alignSelf={["center", null, "initial"]}>
          <a href="/app/sign-up">
            Start transfer now
            <ArrowRightIcon />
          </a>
        </Button>

        <VStack w="full" gap="8" py="10">
          <Text size="xl" textAlign="center" fontWeight="medium">
            Works with your favorite music streaming services
          </Text>

          <HStack
            w="full"
            justifyContent="center"
            alignItems="center"
            flexWrap="wrap"
          >
            <VStack
              gap="4"
              p="4"
              w="36"
              border="thin"
              borderStyle="solid"
              borderColor="border.subtle"
              borderRadius="lg"
            >
              <Box w="14" h="14">
                <PlatformLogo platform="spotify" />
              </Box>
              <Text fontSize="lg" fontWeight="medium">
                Spotify
              </Text>
            </VStack>

            <VStack
              gap="4"
              p="4"
              w="36"
              border="thin"
              borderStyle="solid"
              borderColor="border.subtle"
              borderRadius="lg"
            >
              <Box w="14" h="14">
                <PlatformLogo platform="applemusic" />
              </Box>
              <Text fontSize="lg" fontWeight="medium">
                Apple Music
              </Text>
            </VStack>
          </HStack>

          <Text
            size="xl"
            textAlign="center"
            fontWeight="medium"
            color="neutral.10"
          >
            and more to come!
          </Text>
        </VStack>
      </VStack>
    </VStack>
  </ContentContainer>
);

type MarketingCardProps = {
  icon: ReactNode;
  title: string;
  text: string;
};
const MarketingCard = ({ icon, title, text }: MarketingCardProps) => {
  return (
    <Card.Root>
      <Card.Header justifyContent="center" alignItems="center" gap="4">
        {icon}
        <Heading as="h3" size="xl" textAlign="center">
          {title}
        </Heading>
      </Card.Header>
      <Card.Body>
        <Text textAlign="center" color="neutral.11">
          {text}
        </Text>
      </Card.Body>
    </Card.Root>
  );
};

const MarketingCards = () => (
  <ContentContainer bg="bg.muted">
    <Stack
      gap={["10"]}
      direction={["column", null, null, "row"]}
      py={["12", undefined, "24", "32"]}
    >
      <MarketingCard
        icon={<Music2Icon size={28} />}
        title="Musical mobility"
        text="Take your carefully curated playlists and library wherever you go. Switch between services without losing your musical identity."
      />

      <MarketingCard
        icon={<RefreshCwIcon size={28} />}
        title="Freedom to Switch"
        text="Compare prices, features, and music availability. Choose the service that best fits your needs without compromise."
      />

      <MarketingCard
        icon={<SwatchBookIcon size={28} />}
        title="More to Come"
        text="We're just getting started! More streaming services, smart playlist management, and advanced features are on the horizon."
      />
    </Stack>
  </ContentContainer>
);

type ComingSoonItemProps = {
  title: string;
  text: string;
};
const ComingSoonItem = ({ title, text }: ComingSoonItemProps) => (
  <HStack
    border="0.5"
    px="4"
    py="4"
    borderRadius="md"
    borderStyle="solid"
    borderColor="border.default"
    flex="1"
    flexBasis="0"
    justifyContent={["flex-start", null, null, "center"]}
    alignItems="center"
    gap={["4", null, null, "2"]}
  >
    <SparklesIcon size={24} className={css({ flexShrink: "0" })} />
    <VStack gap="1" flex="1">
      <Heading
        as="h3"
        size="xl"
        textAlign={["left", null, null, "center"]}
        w="full"
      >
        {title}
      </Heading>
      <Text
        color="neutral.11"
        textAlign={["left", null, null, "center"]}
        w="full"
      >
        {text}
      </Text>
    </VStack>
  </HStack>
);

const ComingSoon = () => (
  <ContentContainer bg="white">
    <VStack w="full" py={["12", undefined, "24", "32"]} gap="12">
      <Box width="full">
        <Heading as="h2" size="3xl" textAlign="center" mb="4">
          Coming soon
        </Heading>
        <Text textAlign="center" size="xl" color="neutral.11">
          We're working hard to bring you even more amazing features
        </Text>
      </Box>

      <Stack gap={["10"]} direction={["column", null, null, "row"]}>
        <ComingSoonItem
          title="More services"
          text="Tidal, Deezer, Qobuz, Youtube Music and more coming soon!"
        />

        <ComingSoonItem
          title="Playlist management"
          text="Sync & share playlist accross different platforms"
        />

        <ComingSoonItem
          title="Playlist curator profile"
          text="Automatic musical management for playlist curators"
        />
      </Stack>
    </VStack>
  </ContentContainer>
);

const CallToAction = () => (
  <ContentContainer bg="bg.muted">
    <VStack w="full" py={["12", undefined, "24", "32"]} gap="12">
      <Box width="full">
        <Heading as="h2" size="3xl" textAlign="center" mb="4" color="bronze.12">
          Ready to break free?
        </Heading>
        <Text textAlign="center" size="xl" color="neutral.11">
          Join our beta program today and experience the future of music library
          management.
        </Text>
      </Box>

      <Button size="xl" asChild>
        <a href="/app/sign-up">
          Get Started Now
          <ArrowRightIcon />
        </a>
      </Button>
    </VStack>
  </ContentContainer>
);

export const LandingPage = () => {
  return (
    <>
      <Hero />
      <MarketingCards />
      <ComingSoon />
      <CallToAction />
    </>
  );
};
