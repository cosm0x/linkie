import { getDefaultConfig } from "@rainbow-me/rainbowkit";
import { bscTestnet } from "wagmi/chains";

const projectId = process.env.NEXT_PUBLIC_WC_PROJECT_ID as string;

export const config = getDefaultConfig({
  appName: "Linkie - easy links, fast payment!",
  projectId: projectId,
  chains: [bscTestnet],
  ssr: true,
});
