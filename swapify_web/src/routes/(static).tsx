import { ParentProps, Show } from "solid-js";
import { A } from "@solidjs/router";

import { Container, HStack } from "#style/jsx";
import { styled } from "#style/jsx";
import { Button } from "#root/components/ui/button";
import { Text } from "#root/components/ui/text";
import { signOutAction } from "#root/actions/signOutAction";
import { useUser } from "#root/services/auth";

function Navigation() {
  const user = useUser();
  const isConnected = () => Boolean(user() && user()?.status === "ok");

  return (
    // @ts-expect-error
    <HStack as="nav" w="full" h="16" justifyContent="space-between">
      <styled.div>
        <A href="/">
          <Text variant="heading" textStyle="xl" as="span">
            Swapify
          </Text>
        </A>
      </styled.div>
      <HStack flexBasis="0%">
        <Show
          when={isConnected()}
          fallback={
            <>
              <Button size="sm" variant="solid" as="a" href="/signup">
                Sign up
              </Button>
              <Button size="sm" variant="outline" as="a" href="/signin">
                Sign in
              </Button>
            </>
          }
        >
          <Button size="sm" variant="solid" as="a" href="/app">
            Dashboard
          </Button>

          <form method="post" action={signOutAction}>
            <Button size="sm" variant="solid" type="submit">
              Sign out
            </Button>
          </form>
        </Show>
      </HStack>
    </HStack>
  );
}

export default function StaticLayout(props: ParentProps) {
  return (
    // @ts-expect-error
    <Container as="main">
      <Navigation />
      {props.children}
    </Container>
  );
}
