import { Link, useNavigate } from "@tanstack/react-router";
import { isFetchError } from "@ts-rest/react-query/v5";

import { Card } from "#root/components/ui/card";
import { Heading } from "#root/components/ui/heading";
import { Text } from "#root/components/ui/text";
import { tsr } from "#root/services/api";
import { VStack } from "#style/jsx";
import { toaster } from "#root/components/toast";

import {
  SignUpForm,
  SignUpFormData,
  useSignUpForm,
} from "./components/sign-up-form";

export function PageSignup() {
  const form = useSignUpForm();
  const navigate = useNavigate();
  const { mutateAsync: signUpAsync, isPending } = tsr.signupUser.useMutation({
    onSuccess: () => {
      navigate({ to: "/sign-in", search: { justSignedUp: true } });
    },
    onError: (error) => {
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
        return;
      }

      if ("message" in (error.body as {})) {
        toaster.create({
          type: "error",
          // TODO: Do better here
          // @ts-expect-error
          description: error.body.message,
        });
      }
    },
  });

  async function handleSubmit(data: SignUpFormData) {
    signUpAsync({ body: data });
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
