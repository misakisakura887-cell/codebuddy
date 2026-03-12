import { getDefaultConfig } from '@rainbow-me/rainbowkit';
import { arbitrum, optimism, polygon, bsc } from 'wagmi/chains';

export const config = getDefaultConfig({
  appName: 'QuantTrade Web3',
  projectId: process.env.NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID || 'demo-project-id',
  chains: [arbitrum, optimism, polygon, bsc],
  ssr: true,
});
