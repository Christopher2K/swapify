import { useEffect } from "react";
import { Link, useNavigate } from "@tanstack/react-router";

import { Card } from "#root/components/ui/card";
import { Heading } from "#root/components/ui/heading";
import { Text } from "#root/components/ui/text";
import { VStack } from "#style/jsx";
import { ThemedAlert } from "#root/components/themed-alert";

import {
  SignUpForm,
  SignUpFormData,
  useSignUpForm,
} from "./components/sign-up-form";
import { useSignUpMutation } from "./hooks/use-sign-up-mutation";
import { isErrorResponse } from "@ts-rest/core";

export function PageSignup() {
  const form = useSignUpForm();
  const navigate = useNavigate();
  const { signUpAsync, isPending, error } = useSignUpMutation();

  async function handleSubmit(data: SignUpFormData) {
    try {
      await signUpAsync({ body: data });
      navigate({ to: "/sign-in", search: { justSignedUp: true } });
    } catch (_) {}
  }

  useEffect(() => {
    if (isErrorResponse(error) && error?.status === 422) {
      for (const [field, errorMsg] of Object.entries(error.body.errors.form)) {
        // @ts-expect-error :(
        form.setError(field, {
          type: "manual",
          message: errorMsg,
        });
      }
    }
  }, [error]);

  return (
    <VStack w="100%">
      <VStack py="10">
        <Heading textAlign="center" as="h1" textStyle="6xl">
          Swapify
        </Heading>
        <Text textAlign="center" textStyle="xl" textWrap="balance">
          Create an account and start transfering your playing now!
        </Text>
        <ThemedAlert
          severity="info"
          title="Important information"
          description="Swapify is in closed beta. You can still register but you won't be able to use the app before being approved."
        />
      </VStack>

      <Card.Root w="full" maxW="lg" p="5">
        <Card.Body pt="5">
          <SignUpForm
            form={form}
            handleSubmit={handleSubmit}
            isLoading={isPending}
          />
        </Card.Body>
        <Card.Footer>
          <Link to="/sign-in">Already have an account?</Link>
        </Card.Footer>
      </Card.Root>
    </VStack>
  );
}
