import { Link, useNavigate, useSearch } from "@tanstack/react-router";

import { ThemedAlert } from "#root/components/themed-alert";
import { Card } from "#root/components/ui/card";
import { Heading } from "#root/components/ui/heading";
import { Text } from "#root/components/ui/text";
import { css } from "#style/css";
import { VStack } from "#style/jsx";

import {
  SignInForm,
  SignInFormData,
  useSignInForm,
} from "./components/sign-in-form";
import { useSignInMutation } from "./hooks/use-sign-in-mutation";

export function PageSignin() {
  const { from } = useSearch({
    from: "/unauthenticated/sign-in",
  });
  const form = useSignInForm();
  const navigate = useNavigate();
  const { signInAsync, isPending } = useSignInMutation();

  async function handleSubmit(data: SignInFormData) {
    try {
      await signInAsync({ body: data });
      navigate({ to: "/" });
    } catch (error) {}
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
        <ThemedAlert
          severity="info"
          title="Important information"
          description="Swapify is in closed beta. You can still register but you won't be able to use the app before being approved."
        />
      </VStack>

      <Card.Root w="full" maxW="lg" p="5">
        {from === "sign-up" && (
          <Card.Header>
            <ThemedAlert
              title="Thanks for signing up!"
              description="Your account has been created but you cannot sign in yet. As we're in beta, we will let you know when we have an open spot!"
              severity="success"
            />
          </Card.Header>
        )}

        {from === "password-reset" && (
          <Card.Header>
            <ThemedAlert
              title="Your password has been changed!"
              description="Try to sign in with your new password."
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
        <Card.Footer
          flexDirection={["column", undefined, "row"]}
          justifyContent={["flex-start", undefined, "space-between"]}
          alignItems={["center", undefined, "flex-start"]}
          gap="4"
        >
          <Link to="/password-reset" className={css({ textAlign: "center" })}>
            Reset your password
          </Link>
          <Link to="/sign-up" className={css({ textAlign: "center" })}>
            Don't have an account?
          </Link>
        </Card.Footer>
      </Card.Root>
    </VStack>
  );
}
