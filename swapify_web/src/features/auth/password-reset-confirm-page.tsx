import { useParams, useNavigate } from "@tanstack/react-router";

import { VStack } from "#style/jsx";
import { Heading } from "#root/components/ui/heading";
import { Text } from "#root/components/ui/text";
import { Card } from "#root/components/ui/card";
import { toaster } from "#root/components/toast";

import {
  PasswordResetConfirmationForm,
  type PasswordResetConfirmationFormData,
} from "./components/password-reset-confirmation-form";
import { usePasswordResetConfirmationMutation } from "./hooks/use-password-reset-confirmation-mutation";

export function PasswordResetConfirmPage() {
  const navigate = useNavigate();
  const { code } = useParams({
    from: "/app/unauthenticated/password-reset/$code",
  });

  const { passwordResetConfirmationAsync, isPending, isSuccess } =
    usePasswordResetConfirmationMutation();

  async function handleSubmit(data: PasswordResetConfirmationFormData) {
    try {
      await passwordResetConfirmationAsync({
        body: {
          password: data.password,
          code,
        },
      });

      toaster.success({
        description:
          "Password changed. You can now sign in with your new password.",
      });

      navigate({ to: "/app/sign-in", search: { from: "password-reset" } });
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
        <Card.Body pt="5">
          <PasswordResetConfirmationForm
            isSubmitDisabled={isSuccess}
            isLoading={isPending}
            handleSubmit={handleSubmit}
          />
        </Card.Body>
      </Card.Root>
    </VStack>
  );
}
