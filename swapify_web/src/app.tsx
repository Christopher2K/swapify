import { MetaProvider, Title } from "@solidjs/meta";
import { Router } from "@solidjs/router";
import { FileRoutes } from "@solidjs/start/router";
import { Suspense } from "solid-js";

import "#root/app.css";
import "#style/styles.css";

import { UserProvider } from "#root/services/auth";

export default function App() {
  return (
    <Router
      root={(props) => (
        <MetaProvider>
          <Title>Swapify | Set your music free</Title>
          <Suspense>
            <UserProvider>{props.children}</UserProvider>
          </Suspense>
        </MetaProvider>
      )}
    >
      <FileRoutes />
    </Router>
  );
}
