import { Fragment } from "react";

import { Text } from "#root/components/ui/text";
import { css } from "#style/css";
import { VStack } from "#style/jsx";

const rootClass = css({
  "& dd": {
    marginBottom: "4",
  },
  "& dd:last-of-type": {
    marginBottom: "0",
  },
});

export type DefinitionListProps = {
  items: Array<{ title: string; value: string }>;
};

export const DefinitionList = ({ items }: DefinitionListProps) => {
  return (
    <VStack
      className={rootClass}
      // @ts-expect-error
      as="dl"
      w="full"
      justifyContent="flex-start"
      alignItems="flex-start"
      gap="0"
    >
      {items.map(({ title, value }) => (
        <Fragment key={title}>
          <Text as="dt" textStyle="sm" fontWeight="bold">
            {title}
          </Text>
          <Text as="dd">{value}</Text>
        </Fragment>
      ))}
    </VStack>
  );
};
