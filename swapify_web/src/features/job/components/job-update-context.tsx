import { createContext, type PropsWithChildren, useContext } from "react";

import { useJobUpdateSocket } from "../hooks/use-job-update-socket";

type JobUpdateContextType = {
  addJobUpdateEventListener: ReturnType<
    typeof useJobUpdateSocket
  >["addEventListener"];
};

const JobUpdateContext = createContext<null | JobUpdateContextType>(null);

type JobUpdateContextProviderProps = PropsWithChildren;
export function JobUpdateContextProvider({
  children,
}: JobUpdateContextProviderProps) {
  const { addEventListener } = useJobUpdateSocket();

  return (
    <JobUpdateContext.Provider
      value={{
        addJobUpdateEventListener: addEventListener,
      }}
    >
      {children}
    </JobUpdateContext.Provider>
  );
}

export function useJobUpdateContext() {
  const ctx = useContext(JobUpdateContext);
  if (!ctx)
    throw new Error(
      "useJobUpdateContext must be used inside <JobUpdateContextProvider />",
    );

  return ctx;
}
