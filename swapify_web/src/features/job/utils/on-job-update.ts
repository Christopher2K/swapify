import type { JobUpdateSocketIncomingMessageRecord } from "../hooks/use-job-update-socket";

type JobName =
  JobUpdateSocketIncomingMessageRecord["job_update"]["payload"]["name"];

export function onJobUpdate<T extends JobName>(
  jobName: T,
  onSuccess: (
    payload: Extract<
      Extract<
        JobUpdateSocketIncomingMessageRecord["job_update"]["payload"],
        { name: T }
      >,
      { tag: "JobUpdateNotification" }
    >,
  ) => void,
  onError?: (
    payload: Extract<
      Extract<
        JobUpdateSocketIncomingMessageRecord["job_update"]["payload"],
        { name: T }
      >,
      { tag: "JobErrorNotification" }
    >,
  ) => void,
) {
  return function (
    payload: JobUpdateSocketIncomingMessageRecord["job_update"]["payload"],
  ) {
    if (payload.name === jobName) {
      if (payload.tag === "JobUpdateNotification") {
        // @ts-expect-error: TS cannot infer that we already filtered out all the possible job names
        return onSuccess(payload);
      } else if (payload.tag === "JobErrorNotification") {
        // @ts-expect-error
        return onError(payload);
      }
    } else {
      return;
    }
  };
}
