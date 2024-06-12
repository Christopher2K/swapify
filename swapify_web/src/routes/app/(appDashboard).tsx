import { Button } from "#root/components/ui/button";

export default function AppDashboard() {
  return (
    <>
      <form method="get" action="/api/integrations/spotify/login">
        <Button type="submit">Link spotify account</Button>
      </form>
    </>
  );
}
