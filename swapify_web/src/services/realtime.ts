import { Channel, Socket } from "phoenix";
import { useEffect, useRef, useState } from "react";

import { useMeta } from "#root/features/meta/components/meta-provider";

import type {
  IncomingMessageRecord,
  OutgoingMessageRecord,
} from "./realtime.types";

const socketURL = import.meta.env.PUBLIC_API_URL + "/user_socket";

function connectSocket(token: string) {
  const socket = new Socket(socketURL, {
    params: {
      token,
    },
    logger: (kind, msg, data) => {
      console.debug("[Socket]", kind, msg, data);
    },
  });

  return socket;
}

export function useSocket() {
  const { socketToken } = useMeta();
  const [socket] = useState<Socket>(() => {
    return connectSocket(socketToken);
  });

  useEffect(() => {
    if (!socket.isConnected()) {
      socket.connect();
    }

    return () => {
      if (socket.isConnected()) {
        socket.disconnect();
      }
    };
  }, []);

  return socket;
}

export function useChannel<
  IN extends IncomingMessageRecord,
  OUT extends OutgoingMessageRecord,
>(channelName: string) {
  const socket = useSocket();
  const [channel] = useState(() => socket.channel(channelName));
  const { current: eventListenersMap } = useRef(
    {} as Record<Extract<keyof IN, string>, number[]>,
  );

  function sendMessage<T extends Extract<keyof OUT, string>>(
    message: T,
    payload: OUT[T]["payload"],
  ): Promise<OUT[T]["response"]> {
    const push = channel.push(message, payload);

    return new Promise((resolve, reject) => {
      push.receive("ok", (response) => {
        resolve(response);
      });
      push.receive("error", (response) => {
        reject(response);
      });
    });
  }

  // TODO: Remove the subscription id from the subscription map
  // When the `off` callback is fired
  function addEventListener<T extends Extract<keyof IN, string>>(
    message: T,
    callback: (payload: IN[T]["payload"], channel: Channel) => void,
  ) {
    const subscriptionId = channel.on(message, (payload) => {
      callback(payload, channel);
    });

    if (!eventListenersMap[message]) {
      eventListenersMap[message] = [];
    }

    eventListenersMap[message].push(subscriptionId);

    return () => {
      channel.off(message, subscriptionId);
    };
  }

  useEffect(() => {
    if (channel.state !== "joined" && channel.state !== "joining") {
      channel.join();
    }

    return () => {
      if (channel.state === "joined") {
        channel.leave();
      }
    };
  }, []);

  return {
    sendMessage,
    addEventListener,
  };
}
