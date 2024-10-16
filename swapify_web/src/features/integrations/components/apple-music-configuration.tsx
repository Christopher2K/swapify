import { SquareArrowOutUpRightIcon } from "lucide-react";
import { useRef, useState } from "react";

import AppleMusicIcon from "#root/components/icons/apple-music.svg?react";
import { LoadingContainer } from "#root/components/loading-container";
import { Button } from "#root/components/ui/button";
import { Heading } from "#root/components/ui/heading";
import { Text } from "#root/components/ui/text";
import { useAppleDeveloperTokenQuery } from "#root/features/integrations/hooks/use-apple-developer-token-query";
import { useMusicKit } from "#root/features/integrations/hooks/use-music-kit";
import { tsr } from "#root/services/api";

import { css } from "#style/css";
import { VStack } from "#style/jsx";

function formatPostMessage(eventType: string, message?: string) {
  return {
    integration: "applemusic",
    eventType: eventType,
    message: message,
  };
}

export function AppleMusicConfiguration() {
  const { current: opener } = useRef(window.opener);
  const { data, isError } = useAppleDeveloperTokenQuery();
  const { mutateAsync: updateAppleMusicUserTokenAsync } =
    tsr.updateAppleMusicUserToken.useMutation();
  const musicKitInstance = useMusicKit(data?.developerToken);
  const [authorizationIsLoading, setAuthorizationIsLoading] = useState(false);

  const isLoading = !data || !musicKitInstance;

  async function authorizeRequest() {
    if (!musicKitInstance) return;
    setAuthorizationIsLoading(true);

    try {
      const musicUserToken = await musicKitInstance.authorize();
      await updateAppleMusicUserTokenAsync({
        body: {
          authToken: musicUserToken,
        },
      });
    } catch (_) {
      opener.postMessage(formatPostMessage("error"));
      setAuthorizationIsLoading(false);
      window.close();
      return;
    }

    setAuthorizationIsLoading(false);
    opener.postMessage(formatPostMessage("success"));
    window.close();
  }

  if (isError) {
    opener.postMessage(
      formatPostMessage(
        "error",
        "Error while Apple Music metadata. Please try again or contact support.",
      ),
    );
    window.close();
  }

  if (isLoading) return <LoadingContainer />;

  return (
    <VStack w="full" h="full" p="4" maxW="500px" mx="auto" gap="10">
      <AppleMusicIcon className={css({ w: "80px", h: "auto" })} />
      <Heading as="h1" size="2xl" textAlign="center">
        Connect Swapify to your Apple Music account
      </Heading>
      <VStack gap="4">
        <Text textAlign="center">
          For Swapify to be able to sync your library, get your playlist, and
          transfer your music from other platforms, we need to connect your
          Apple Music account to our systems.
        </Text>

        <Text textAlign="center">
          We cannot acces your iCloud data. We will only be able to see your
          music and playlists on Apple Music. Your can revoke your access at any
          time.
        </Text>
      </VStack>
      <Button
        onClick={authorizeRequest}
        loading={authorizationIsLoading}
        size="xl"
      >
        <SquareArrowOutUpRightIcon />
        Connect
      </Button>
    </VStack>
  );
}
