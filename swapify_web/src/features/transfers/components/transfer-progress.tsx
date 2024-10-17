import { Progress } from "#root/components/ui/progress";
import { Text } from "#root/components/ui/text";
import { VStack } from "#style/jsx";

export type TransferProgressProps = {
  progressText?: (current: number, max: number) => string;
  current: number;
  max: number;
};

export function TransferProgress({
  current,
  max,
  progressText,
}: TransferProgressProps) {
  return (
    <VStack justifyContent="flex-start" alignItems="flex-start" gap="0">
      {progressText && (
        <Text color="gray.9" textStyle="sm" mb="2" fontWeight="medium">
          {progressText(current, max)}
        </Text>
      )}
      <Progress
        translations={{ value: () => "" }}
        min={0}
        max={max}
        value={current}
      />
    </VStack>
  );
}
