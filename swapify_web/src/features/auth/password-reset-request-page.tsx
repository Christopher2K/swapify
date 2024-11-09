import { Link } from "@tanstack/react-router";

import { VStack } from "#style/jsx";
import { Heading } from "#root/components/ui/heading";
import { Text } from "#root/components/ui/text";
import { Card } from "#root/components/ui/card";
import { toaster } from "#root/components/toast";

import {
  PasswordResetRequestForm,
  PasswordResetRequestFormData,
} from "./components/password-reset-request-form";
import { usePasswordResetRequestMutation } from "./hooks/use-password-reset-request-mutation";

export function PasswordResetRequestPage() {
  const { passwordResetRequestAsync, isPending, isSuccess } =
    usePasswordResetRequestMutation();

  async function handleSubmit(data: PasswordResetRequestFormData) {
    try {
      await passwordResetRequestAsync({ body: data });
      toaster.success({
        description:
          "Request sent. If you have a Swapify account, you should get a email in the next minutes.",
      });
    } catch (_) {}
  }

  return (
    <VStack w="100%">
      <VStack py="10">
        <Heading textAlign="center" as="h1" textStyle="6xl">
          Swapify
        </Heading>
        <Text textAlign="center" textStyle="xl" textWrap="balance">
          Reset your account password
        </Text>
      </VStack>

      <Card.Root w="full" maxW="lg" p="5">
        <Card.Header pb="0">
          <Heading as="h2" textStyle="lg">
            Reset your password
          </Heading>
        </Card.Header>
        <Card.Body pt="5">
          <PasswordResetRequestForm
            isLoading={isPending}
            isSubmitDisabled={isSuccess}
            handleSubmit={handleSubmit}
          />
        </Card.Body>
        <Card.Footer>
          <Link to="/sign-in">Already have an account?</Link>
        </Card.Footer>
      </Card.Root>
    </VStack>
  );
}
