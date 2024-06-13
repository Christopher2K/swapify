import { Show } from "solid-js";

import { vstack } from "#style/patterns";
import { Stack, styled, VStack } from "#style/jsx";
import { Input } from "#root/components/ui/input";
import { Button } from "#root/components/ui/button";
import { FormLabel } from "#root/components/ui/form-label";
import * as Card from "#root/components/ui/card";
import * as Alert from "#root/components/ui/alert";
import { signUpAction } from "#root/actions/signUpAction";
import { useSubmission } from "@solidjs/router";

function SignupForm() {
  const signUpSubmission = useSubmission(signUpAction);
  const isSuccessfulSubmission = () =>
    signUpSubmission.result?.status === "success";

  return (
    <Card.Root width="lg" maxW="full">
      <Card.Header>
        <Card.Title>Join us!</Card.Title>
        <Card.Description>Ready to transfer some music?</Card.Description>
      </Card.Header>

      <Card.Body>
        <VStack>
          <Show when={signUpSubmission.result}>
            {(result) => (
              <Alert.Root>
                <Alert.Content>
                  <Alert.Title>
                    {result().status === "success" ? "You're in!" : "Error"}
                  </Alert.Title>
                  <Alert.Description>{result().message}</Alert.Description>
                </Alert.Content>
              </Alert.Root>
            )}
          </Show>

          <Show when={!isSuccessfulSubmission()}>
            <styled.form
              action={signUpAction}
              class={vstack()}
              id="signup"
              w="full"
              gap="4"
              method="post"
            >
              <Stack w="full" gap="1.5">
                <FormLabel>Username</FormLabel>
                <Input
                  name="username"
                  type="text"
                  required
                  maxLengh="20"
                  minLength="3"
                />
              </Stack>
              <Stack w="full" gap="1.5">
                <FormLabel>Email</FormLabel>
                <Input name="email" type="email" required />
              </Stack>
              <Stack w="full" gap="1.5">
                <FormLabel>Password</FormLabel>
                <Input name="password" type="password" required />
              </Stack>
            </styled.form>
          </Show>
        </VStack>
      </Card.Body>
      <Card.Footer>
        <VStack w="full">
          <Show
            when={isSuccessfulSubmission()}
            fallback={
              <>
                <Button
                  variant="link"
                  textDecoration="underline"
                  href="/signin"
                  as="a"
                >
                  I already have an account
                </Button>
                <Button size="xl" form="signup" type="submit">
                  Sign up
                </Button>
              </>
            }
          >
            <Button as="a" href="/signin">
              Sign in now!
            </Button>
          </Show>
        </VStack>
      </Card.Footer>
    </Card.Root>
  );
}

export default function Signup() {
  return (
    <VStack>
      <SignupForm />
    </VStack>
  );
}
