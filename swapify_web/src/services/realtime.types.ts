export type IncomingMessageRecord = Record<
  string,
  {
    payload: object;
  }
>;

export type OutgoingMessageRecord = Record<
  string,
  {
    payload: object;
    response: object;
  }
>;

type APIJobNotification<TAG extends string, DATA> = {
  name: string;
  data: DATA;
  tag: TAG;
};

export type APIJobErrorNotification<T> = APIJobNotification<
  "JobErrorNotification",
  T
>;

export type APIJobUpdateNotification<T> = APIJobNotification<
  "JobUpdateNotification",
  T
>;
