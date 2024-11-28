import {
  SparklesIcon,
  ArrowRightIcon,
  Music2Icon,
  RefreshCwIcon,
  SwatchBookIcon,
} from "lucide-react";

import { Text } from "#root/components/ui/text";
import { VStack, HStack, Box, type BoxProps, Stack } from "#style/jsx";
import { css } from "#style/css";
import { Heading } from "#root/components/ui/heading";
import type { PropsWithChildren } from "react";
import { Button } from "#root/components/ui/button";
import { Card } from "#root/components/ui/card";
import type { ReactNode } from "@tanstack/react-router";

const ContentContainer = ({
  children,
  ...props
}: PropsWithChildren & BoxProps) => (
  <Box w="full" mx="auto" {...props}>
    <Box maxWidth="1400px" w="full" mx="auto" px="10">
      {children}
    </Box>
  </Box>
);

const BetaBanner = () => (
  <Box
    backgroundColor="neutral.12"
    width="full"
    justifyContent="center"
    alignItems="center"
    gap="2"
    px="2"
    py="2"
  >
    <Text color="neutral.1" size="sm" fontWeight="medium" textAlign="center">
      <SparklesIcon
        className={css({
          stroke: "neutral.1",
          display: "inline",
          marginRight: "2",
        })}
        size={16}
      />
      Currently in beta - Early access available now!
    </Text>
  </Box>
);

const Hero = () => (
  <ContentContainer bg="white">
    <VStack
      w="full"
      gap="4"
      justifyContent="center"
      alignItems="center"
      py={["12", undefined, "24", "32", "48"]}
    >
      <Heading
        as="h1"
        size={["5xl", null, null, "7xl"]}
        textAlign="center"
        textWrap="balance"
      >
        Your Music, Your Choice
      </Heading>
      <Heading
        as="h2"
        size="xl"
        textAlign="center"
        textWrap="balance"
        fontWeight="medium"
        color="neutral.11"
        mb="10"
      >
        Seamlessly transfer your music library between Spotify and Apple Music.
        <br />
        Take control of your musical journey.
      </Heading>

      <Button size="2xl" asChild>
        <a href="/app">
          Start transfer now
          <ArrowRightIcon className={css({})} />
        </a>
      </Button>
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
    borderColor="neutral.4"
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
          title="Playlist manageement"
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
        <Heading as="h2" size="3xl" textAlign="center" mb="4">
          Ready to break free?
        </Heading>
        <Text textAlign="center" size="xl" color="neutral.11">
          Join our beta program today and experience the future of music library
          management.
        </Text>
      </Box>

      <Button size="xl" asChild>
        <a href="/app">
          Get Started Now
          <ArrowRightIcon className={css({})} />
        </a>
      </Button>
    </VStack>
  </ContentContainer>
);

const Footer = () => (
  <ContentContainer bg="white">
    <VStack w="full" py="12">
      <Text>© 2024 Swapify. All rights reserved.</Text>
    </VStack>
  </ContentContainer>
);

export const LandingPage = () => {
  return (
    <Box>
      <BetaBanner />
      <Hero />
      <MarketingCards />
      <ComingSoon />
      <CallToAction />
      <Footer />
    </Box>
  );
};
