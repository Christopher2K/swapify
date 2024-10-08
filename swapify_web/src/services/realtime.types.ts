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

type APIJobNotification<TAG extends string, NAME extends string, DATA> = {
  name: NAME;
  data: DATA;
  tag: TAG;
};

export type APIJobErrorNotification<
  NAME extends string,
  T,
> = APIJobNotification<"JobErrorNotification", NAME, T>;

export type APIJobUpdateNotification<
  NAME extends string,
  T,
> = APIJobNotification<"JobUpdateNotification", NAME, T>;
