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
