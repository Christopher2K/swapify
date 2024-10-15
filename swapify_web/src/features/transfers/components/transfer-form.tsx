import { useMemo } from "react";
import { useForm } from "react-hook-form";
import { z } from "zod";

import { toaster } from "#root/components/toast";
import {
  SchemaForm,
  SelectSchema,
  PlatformNameSchema,
} from "#root/components/schema-form";
import { useLibrariesQuery } from "#root/features/playlists/hooks/use-libraries-query";
import { getPlatformName } from "#root/features/integrations/utils/get-platform-name";
import { useIntegrationsQuery } from "#root/features/integrations/hooks/use-integrations-query";
import { PlatformLogo } from "#root/components/platform-logo";
import { Select } from "#root/components/ui/select";
import { APIPlatformName } from "#root/services/api.types";
import { useStartPlaylistTransferMutation } from "#root/features/transfers/hooks/use-start-playlist-transfer-mutation";

import { styled } from "#style/jsx";
import { css } from "#style/css";

export const TRANSFER_FORM_ID = "transfer-form";

const TransferFormSchema = z.object({
  playlist: SelectSchema.describe(
    "Source playlist // Select a playlist to transfer",
  ),
  destination: PlatformNameSchema.describe(
    "Destination platform // Select a destination platform",
  ),
});

export type TransferFormData = z.infer<typeof TransferFormSchema>;

export type TransferFormProps = {
  handleSubmit: (data: z.infer<typeof TransferFormSchema>) => void;
};

export const TransferForm = () => {
  const form = useForm<z.infer<typeof TransferFormSchema>>();
  const values = form.watch();
  const { libraries = [] } = useLibrariesQuery({
    status: ["synced", "error"],
  });
  const { integrations = [] } = useIntegrationsQuery();
  const { startPlaylistTransferAsync, isPending } =
    useStartPlaylistTransferMutation();

  const selectedLibrary = useMemo(
    () => libraries?.find((lib) => lib.id === values.playlist),
    [libraries, values.playlist],
  );

  async function handleSubmit(data: z.infer<typeof TransferFormSchema>) {
    if (!selectedLibrary) return;
    if (!values.destination) return;

    if (selectedLibrary.platformName === data.destination) {
      toaster.create({
        title: "Invalid transfer",
        description:
          "You can't transfer a library to the same platform it belongs",
        type: "error",
      });
      return;
    }

    try {
      await startPlaylistTransferAsync({
        body: {
          playlist: values.playlist,
          destination: values.destination,
        },
      });

      toaster.create({
        title: "Transfer started",
        description:
          "A new library transfer has been started. You will be notified when it's done.",
        type: "success",
      });
    } catch (error) {}
  }

  return (
    <SchemaForm
      schema={TransferFormSchema}
      onSubmit={handleSubmit}
      form={form}
      formProps={{
        submitText: "Start transfer",
        isLoading: isPending,
        formItemsContainerClassName: css({
          w: "full",
          display: "flex",
          flexDirection: "column",
          justifyContent: "flex-start",
          alignItems: "flex-start",
          gap: "6",
          "@container (width > 600px)": {
            flexDirection: "row",
          },
        }),
      }}
      props={{
        playlist: {
          items: libraries.map((item) => ({
            label: `${getPlatformName(item.platformName)} library`,
            value: item.id,
            renderLeftIcon: () => <PlatformLogo platform={item.platformName} />,
          })),
          helperText:
            "Only synchronized playlists can be selected. If you don't see your playlist here, please sync it first.",
          renderValue: (placeholder?: string) => (
            <>
              {selectedLibrary ? (
                <Select.ValueText
                  display="flex"
                  flexDir="row"
                  justifyContent="flex-start"
                  alignItems="center"
                  gap="2"
                >
                  <styled.span display="inline-block" h="4" w="4">
                    <PlatformLogo platform={selectedLibrary.platformName} />
                  </styled.span>
                  {getPlatformName(selectedLibrary.platformName)} library
                </Select.ValueText>
              ) : (
                <Select.ValueText placeholder={placeholder} />
              )}
            </>
          ),
        },
        destination: {
          items: integrations
            .filter((item) => item.name !== selectedLibrary?.platformName)
            .map((item) => ({
              label: getPlatformName(item.name),
              value: item.name,
              renderLeftIcon: () => <PlatformLogo platform={item.name} />,
            })),
          renderValue: (placeholder?: string, platformName?: string) => (
            <>
              {platformName ? (
                <Select.ValueText
                  display="flex"
                  flexDir="row"
                  justifyContent="flex-start"
                  alignItems="center"
                  gap="2"
                >
                  <styled.span display="inline-block" h="4" w="4">
                    <PlatformLogo platform={platformName as APIPlatformName} />
                  </styled.span>
                  {getPlatformName(platformName as APIPlatformName)}
                </Select.ValueText>
              ) : (
                <Select.ValueText placeholder={placeholder} />
              )}
            </>
          ),
        },
      }}
    />
  );
};
