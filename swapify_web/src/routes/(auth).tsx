import { A, RouteSectionProps } from "@solidjs/router";

import { VStack, Container } from "#style/jsx";
import { Text } from "#root/components/ui/text";

import { anonymousRouteCheck } from "#root/services/auth";

export default function AuthLayout(props: RouteSectionProps) {
  anonymousRouteCheck();

  return (
    // @ts-expect-error
    <Container as="main">
      {/* @ts-expect-error */}
      <VStack as="header" py="10">
        <A href="/">
          <Text textStyle="6xl" fontWeight="semibold">
            Swapify
          </Text>
        </A>
      </VStack>
      {props.children}
    </Container>
  );
}
