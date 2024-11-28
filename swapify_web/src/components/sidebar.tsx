import { Link } from "@tanstack/react-router";
import {
  LayoutDashboardIcon,
  MusicIcon,
  ToyBrickIcon,
  FolderSyncIcon,
} from "lucide-react";
import type { ComponentProps, ReactNode } from "react";

import { css } from "#style/css";
import { VStack } from "#style/jsx";

import { getApiUrl } from "#root/services/api";
import { Button } from "./ui/button";

type SidebarLinkProps = {
  to: ComponentProps<typeof Link>["to"];
  label: string;
  icon: ReactNode;
  exact?: boolean;
};
const SidebarLink = ({ to, label, icon, exact = true }: SidebarLinkProps) => {
  return (
    <Button
      variant="ghost"
      size="md"
      width="full"
      justifyContent="flex-start"
      fontWeight="medium"
      asChild
    >
      <Link
        to={to}
        activeProps={{ className: css({ bg: "bg.emphasized" }) }}
        activeOptions={{ exact: exact }}
      >
        {icon}
        {label}
      </Link>
    </Button>
  );
};

export type SidebarProps = {
  navProps?: ComponentProps<typeof VStack>;
  isMobileOpen?: boolean;
};

export function Sidebar({ navProps, isMobileOpen }: SidebarProps) {
  return (
    <VStack
      /* @ts-expect-error */
      as="aside"
      position="absolute"
      top={0}
      left={0}
      width={["85%", "300px"]}
      height="100%"
      bg="bg.default"
      p="4"
      gap="4"
      zIndex="overlay"
      transition="all"
      transitionTimingFunction="ease-in-out"
      transitionDuration="fast"
      borderRight={["thin", "none"]}
      borderStyle="solid"
      borderColor="border.default"
      transform={[
        isMobileOpen ? "translateX(0)" : "translateX(-100%)",
        "translateX(0)",
      ]}
      {...navProps}
    >
      <VStack flex="1" w="full" gap="1">
        <SidebarLink
          to="/app"
          label="Dashboard"
          icon={<LayoutDashboardIcon strokeWidth="2" />}
        />
        <SidebarLink
          to="/app/transfers"
          label="Transfers"
          icon={<FolderSyncIcon strokeWidth="2" />}
        />
        <SidebarLink
          to="/app/playlists"
          label="Playlists"
          icon={<MusicIcon strokeWidth="2" />}
        />
        <SidebarLink
          to="/app/integrations"
          label="Music platforms"
          icon={<ToyBrickIcon strokeWidth="2" />}
        />
      </VStack>
      <Link
        to={getApiUrl("/api/auth/signout")}
        className={css({
          width: "full",
          display: "flex",
          alignItems: "center",
        })}
      >
        <Button width="full" size="sm" variant="outline">
          Sign out
        </Button>
      </Link>
    </VStack>
  );
}
