import { Show } from "solid-js";
import { useSubmission } from "@solidjs/router";

import { vstack } from "#style/patterns";
import { Stack, styled, VStack } from "#style/jsx";
import { Input } from "#root/components/ui/input";
import { Button } from "#root/components/ui/button";
import { FormLabel } from "#root/components/ui/form-label";
import * as Card from "#root/components/ui/card";
import * as Alert from "#root/components/ui/alert";
import { signInAction } from "#root/lib/auth/auth-actions";

function SigninForm() {
  const signInSubmission = useSubmission(signInAction);

  return (
    <Card.Root width="lg" maxW="full">
      <Card.Header>
        <Card.Title>Welcome back</Card.Title>
        <Card.Description>Ready to transfer some music?</Card.Description>
      </Card.Header>
      <Card.Body>
        <styled.form
          action={signInAction}
          class={vstack()}
          id="signin"
          w="full"
          gap="4"
          method="post"
        >
          <Show when={signInSubmission.result}>
            {(result) => (
              <Alert.Root>
                <Alert.Content>
                  <Alert.Title>Error</Alert.Title>
                  <Alert.Description>{result().error}</Alert.Description>
                </Alert.Content>
              </Alert.Root>
            )}
          </Show>
          <Stack w="full" gap="1.5">
            <FormLabel>Email</FormLabel>
            <Input name="email" type="email" required />
          </Stack>
          <Stack w="full" gap="1.5">
            <FormLabel>Password</FormLabel>
            <Input name="password" type="password" required />
          </Stack>

          <Button size="xl" form="signin" type="submit">
            Sign in
          </Button>
        </styled.form>
      </Card.Body>
      <Card.Footer>
        <VStack w="full">
          <Button
            variant="link"
            textDecoration="underline"
            href="/signup"
            as="a"
          >
            I don't have an account
          </Button>
        </VStack>
      </Card.Footer>
    </Card.Root>
  );
}

export default function Signin() {
  return (
    <VStack>
      <SigninForm />
    </VStack>
  );
}
