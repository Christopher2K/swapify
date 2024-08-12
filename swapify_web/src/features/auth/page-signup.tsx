import { useNavigate, Link } from "@tanstack/react-router";
import { isFetchError } from "@ts-rest/react-query/v5";

import { VStack } from "#style/jsx";
import { Heading } from "#root/components/ui/heading";
import { Text } from "#root/components/ui/text";
import { Card } from "#root/components/ui/card";

import {
  SignUpForm,
  SignUpFormData,
  useSignUpForm,
} from "./components/sign-up-form";
import { useSignupMutation } from "./hooks/use-signup-mutation";

export function PageSignup() {
  const { signupAsync, isLoading, error } = useSignupMutation();
  const navigate = useNavigate();
  const form = useSignUpForm();
  handleError();

  function handleError() {
    if (error == null) return;
    if (isFetchError(error)) return;
    if (error.status === 422) {
      Object.entries(error.body.errors.form ?? {}).forEach(
        ([field, errorMsg]) => {
          // @ts-expect-error :(
          form.setError(field, {
            type: "manual",
            message: errorMsg,
          });
        },
      );
    }
  }

  async function handleSubmit(data: SignUpFormData) {
    try {
      await signupAsync({ body: data });
      navigate({ to: "/sign-in", search: { "just-signed-up": true } });
    } catch (_) {}
  }

  return (
    <VStack w="100%">
      <VStack py="10">
        <Heading textAlign="center" as="h1" textStyle="6xl">
          Swapify
        </Heading>
        <Text textAlign="center" textStyle="xl" textWrap="balance">
          Create an account and start transfering your playing now!
        </Text>
      </VStack>

      <Card.Root w="full" maxW="lg" p="5">
        <Card.Body pt="5">
          <SignUpForm
            form={form}
            handleSubmit={handleSubmit}
            isLoading={isLoading}
          />
        </Card.Body>
        <Card.Footer>
          <Link to="/sign-in">Already have an account?</Link>
        </Card.Footer>
      </Card.Root>
    </VStack>
  );
}
