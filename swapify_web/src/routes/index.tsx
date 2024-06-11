import { Title } from "@solidjs/meta";
import Counter from "#root/components/Counter";
import { Button } from "#root/components/ui/button";

export default function Home() {
  return (
    <main>
      <Title>Hello World</Title>
      <h1>Hello world!</h1>
      <Counter />
      <Button colorPalette="red" variant="solid">
        Hey
      </Button>
      <p>
        Visit{" "}
        <a href="https://start.solidjs.com" target="_blank">
          start.solidjs.com
        </a>{" "}
        to learn how to build SolidStart apps.
      </p>
    </main>
  );
}
