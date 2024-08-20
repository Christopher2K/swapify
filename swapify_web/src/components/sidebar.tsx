import type { ComponentProps, ReactNode } from "react";
import { Link } from "@tanstack/react-router";
import {
  LayoutDashboardIcon,
  ToyBrickIcon,
  XIcon,
  MusicIcon,
} from "lucide-react";

import { VStack } from "#style/jsx";
import { css } from "#style/css";

import { Button } from "./ui/button";
import { Text } from "./ui/text";

type SidebarLinkProps = {
  to: ComponentProps<typeof Link>["to"];
  label: string;
  icon: ReactNode;
};
const SidebarLink = ({ to, label, icon }: SidebarLinkProps) => {
  return (
    <Button
      variant="ghost"
      size="md"
      width="full"
      justifyContent="flex-start"
      asChild
    >
      <Link to={to} activeProps={{ className: css({ bg: "accent.3" }) }}>
        {icon}
        {label}
      </Link>
    </Button>
  );
};

export type SidebarProps = {
  navProps?: ComponentProps<typeof VStack>;
  isMobileOpen?: boolean;
  onMobileClose?: () => void;
};

export function Sidebar({
  navProps,
  isMobileOpen,
  onMobileClose,
}: SidebarProps) {
  return (
    <VStack
      /* @ts-expect-error */
      as="nav"
      position="fixed"
      top="0"
      width={["85%", "300px"]}
      height="100svh"
      bg="accent.1"
      borderRight="thin"
      borderStyle="solid"
      borderColor="accent.4"
      p="4"
      gap="4"
      boxShadow="sm"
      zIndex="overlay"
      transition="all"
      transitionTimingFunction="ease-in-out"
      transitionDuration="fast"
      transform={[
        isMobileOpen ? "translateX(0)" : "translateX(-100%)",
        "translateX(0)",
      ]}
      {...navProps}
    >
      <header
        className={css({
          position: "relative",
          width: "full",
          textAlign: "center",
        })}
      >
        <Text as="h1" textStyle="xl" fontWeight="bold">
          Swapify
        </Text>
        <Button
          variant="link"
          onClick={onMobileClose}
          position="absolute"
          top="0"
          right="0"
          display={["block", "none"]}
        >
          <XIcon strokeWidth="2" />
        </Button>
      </header>
      <VStack flex="1" w="full" gap="4" px="4">
        <SidebarLink
          to="/"
          label="Dashboard"
          icon={<LayoutDashboardIcon strokeWidth="2" />}
        />
        <SidebarLink
          to="/playlists"
          label="Playlists"
          icon={<MusicIcon strokeWidth="2" />}
        />
        <SidebarLink
          to="/integrations"
          label="Music platforms"
          icon={<ToyBrickIcon strokeWidth="2" />}
        />
      </VStack>
      <Button width="full" size="sm">
        Sign out
      </Button>
    </VStack>
  );
}
