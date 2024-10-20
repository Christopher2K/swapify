import { Link, useNavigate, useSearch } from "@tanstack/react-router";
import { isFetchError } from "@ts-rest/react-query/v5";

import { ThemedAlert } from "#root/components/themed-alert";
import { Card } from "#root/components/ui/card";
import { Heading } from "#root/components/ui/heading";
import { Text } from "#root/components/ui/text";
import { VStack } from "#style/jsx";

import {
  SignInForm,
  SignInFormData,
  useSignInForm,
} from "./components/sign-in-form";
import { useSignInMutation } from "./hooks/use-sign-in-mutation";

export function PageSignin() {
  const { justSignedUp } = useSearch({
    from: "/unauthenticated/sign-in",
  });
  const form = useSignInForm();
  const navigate = useNavigate();
  const { signInAsync, isPending } = useSignInMutation();

  async function handleSubmit(data: SignInFormData) {
    try {
      await signInAsync({ body: data });
      navigate({ to: "/" });
    } catch (error) {
      if (error == null) return;
      if (isFetchError(error)) return;
      // @ts-expect-error
      if (error.status === 401) {
        form.setError("root", {
          type: "manual",
          message: "Invalid email or password",
        });
      }
    }
  }

  return (
    <VStack w="100%">
      <VStack py="10">
        <Heading textAlign="center" as="h1" textStyle="6xl">
          Swapify
        </Heading>
        <Text textAlign="center" textStyle="xl" textWrap="balance">
          Sign in to start transferring your music now!
        </Text>
      </VStack>

      <Card.Root w="full" maxW="lg" p="5">
        {justSignedUp && (
          <Card.Header>
            <ThemedAlert
              title="Please sign in to continue"
              description="Your account has been created!"
              severity="success"
            />
          </Card.Header>
        )}
        <Card.Body pt="5">
          <SignInForm
            handleSubmit={handleSubmit}
            form={form}
            isLoading={isPending}
          />
        </Card.Body>
        <Card.Footer>
          <Link to="/sign-up">Don't have an account?</Link>
        </Card.Footer>
      </Card.Root>
    </VStack>
  );
}
