export type IncomingMessageRecord = {
  [message: string]: {
    payload: object;
  };
};

export type OutgoingMessageRecord = {
  [message: string]: {
    payload: object;
    response: object;
  };
};
