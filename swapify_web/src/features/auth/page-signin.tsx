import { Link, useNavigate, useSearch } from "@tanstack/react-router";
import { isFetchError } from "@ts-rest/react-query/v5";

import { Heading } from "#root/components/ui/heading";
import { Text } from "#root/components/ui/text";
import { Card } from "#root/components/ui/card";
import { VStack } from "#style/jsx";
import { tsr } from "#root/services/api";
import { ThemedAlert } from "#root/components/themed-alert";

import {
  SignInForm,
  useSignInForm,
  SignInFormData,
} from "./components/sign-in-form";

export function PageSignin() {
  const { justSignedUp } = useSearch({
    from: "/unauthenticated/sign-in",
  });
  const form = useSignInForm();
  const navigate = useNavigate();
  const { mutateAsync: signInAsync, isPending } = tsr.signinUser.useMutation({
    onSuccess: () => {
      navigate({ to: "/" });
    },
    onError: (error) => {
      if (error == null) return;
      if (isFetchError(error)) return;
      if (error.status === 401) {
        form.setError("root", {
          type: "manual",
          message: "Invalid email or password",
        });
      }
    },
  });

  function handleSubmit(data: SignInFormData) {
    signInAsync({ body: data });
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
