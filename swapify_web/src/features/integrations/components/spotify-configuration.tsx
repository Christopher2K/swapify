import { useEffect, useRef, useState } from "react";
import { SquareArrowOutUpRightIcon } from "lucide-react";

import { Text } from "#root/components/ui/text";
import { Heading } from "#root/components/ui/heading";
import { Button } from "#root/components/ui/button";
import SpotifyIcon from "#root/components/icons/spotify.svg?react";

import { VStack } from "#style/jsx";
import { css } from "#style/css";
import { useSearch } from "@tanstack/react-router";

const SPOTIFY_LOGIN_URL = `${import.meta.env.VITE_API_URL}/api/integrations/spotify/login`;

function formatPostMessage(eventType: string, message?: string) {
  return {
    integration: "spotify",
    eventType: eventType,
    message: message,
  };
}

export function SpotifyConfiguration() {
  const { current: opener } = useRef(window.opener as Window);
  const { result } = useSearch({
    from: "/authenticated/integrations/$integrationName",
  });

  if (result === "success") {
    opener.postMessage(formatPostMessage("success"));
    console.log("success");
    window.close();
  }

  if (result === "error") {
    opener.postMessage(
      formatPostMessage(
        "error",
        "Error while connecting to Spotify. Please try again or contact support.",
      ),
    );
    window.close();
  }

  return (
    <VStack w="full" h="full" p="4" maxW="500px" mx="auto" gap="10">
      <SpotifyIcon className={css({ w: "80px", h: "auto" })} />
      <Heading as="h1" size="2xl" textAlign="center">
        Connect Swapify to your Spotify account
      </Heading>
      <VStack gap="4">
        <Text textAlign="center">
          For Swapify to be able to sync your library, get your playlist, and
          transfer your music from other platforms, we need to connect your
          Spotify account to our systems.
        </Text>

        <Text textAlign="center">Your can revoke your access at any time.</Text>
      </VStack>
      {result !== "success" && (
        <Button size="xl" asChild>
          <a href={SPOTIFY_LOGIN_URL}>
            <SquareArrowOutUpRightIcon />
            Connect
          </a>
        </Button>
      )}
    </VStack>
  );
}
