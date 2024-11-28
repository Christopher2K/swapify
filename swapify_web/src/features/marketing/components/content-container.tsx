import type { PropsWithChildren } from "react";
import { Box, type BoxProps } from "#style/jsx";

export const ContentContainer = ({
  children,
  ...props
}: PropsWithChildren & BoxProps) => (
  <Box w="full" mx="auto" position="relative" {...props}>
    <Box maxWidth="1400px" w="full" mx="auto" px={["4", null, "10"]}>
      {children}
    </Box>
  </Box>
);

// import type { PropsWithChildren } from "react";
//
// import { ContentContainer } from "#root/features/marketing/components/content-container";
//
// export function Container({ children }: PropsWithChildren) {
//   return <ContentContainer>{children}</ContentContainer>;
// }
