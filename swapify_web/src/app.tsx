import { MetaProvider, Title } from "@solidjs/meta";
import { Router } from "@solidjs/router";
import { FileRoutes } from "@solidjs/start/router";
import { Suspense } from "solid-js";

import "#root/app.css";
import "#style/styles.css";

import { UserProvider } from "#root/lib/auth/user-provider";

export default function App() {
  return (
    <Router
      root={(props) => (
        <Suspense>
          <MetaProvider>
            <Title>Swapify | Set your music free</Title>
            <UserProvider>{props.children}</UserProvider>
          </MetaProvider>
        </Suspense>
      )}
    >
      <FileRoutes />
    </Router>
  );
}
