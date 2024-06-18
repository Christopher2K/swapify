import { KyInstance } from "ky";

export type RemoteData<T> = {
  data: T;
};

export type RemoteArgs<T = void> = T extends void
  ? {
      client?: KyInstance;
    }
  : {
      client?: KyInstance;
      data: T;
    };

type SuccessResponse<T> = {
  status: "ok";
  data: T;
};

type ErrorResponse<T> = {
  status: "error";
  code?: number;
  data?: T;
};

export type APIResponse<T, E = {}> = SuccessResponse<T> | ErrorResponse<E>;
