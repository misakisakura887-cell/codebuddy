export const SUPPORTED_CHAINS = {
  arbitrum: {
    id: 42161,
    name: 'Arbitrum One',
    rpcUrl: process.env.NEXT_PUBLIC_ARBITRUM_RPC || 'https://arb1.arbitrum.io/rpc',
    explorer: 'https://arbiscan.io',
    nativeCurrency: { name: 'ETH', symbol: 'ETH', decimals: 18 },
    contracts: {
      vault: '0x0000000000000000000000000000000000000000',
      gridStrategy: '0x0000000000000000000000000000000000000000',
      copyTrading: '0x0000000000000000000000000000000000000000',
    },
  },
  optimism: {
    id: 10,
    name: 'Optimism',
    rpcUrl: process.env.NEXT_PUBLIC_OPTIMISM_RPC || 'https://mainnet.optimism.io',
    explorer: 'https://optimistic.etherscan.io',
    nativeCurrency: { name: 'ETH', symbol: 'ETH', decimals: 18 },
    contracts: {
      vault: '0x0000000000000000000000000000000000000000',
      gridStrategy: '0x0000000000000000000000000000000000000000',
      copyTrading: '0x0000000000000000000000000000000000000000',
    },
  },
  polygon: {
    id: 137,
    name: 'Polygon',
    rpcUrl: process.env.NEXT_PUBLIC_POLYGON_RPC || 'https://polygon-rpc.com',
    explorer: 'https://polygonscan.com',
    nativeCurrency: { name: 'MATIC', symbol: 'MATIC', decimals: 18 },
    contracts: {
      vault: '0x0000000000000000000000000000000000000000',
      gridStrategy: '0x0000000000000000000000000000000000000000',
      copyTrading: '0x0000000000000000000000000000000000000000',
    },
  },
  bsc: {
    id: 56,
    name: 'BNB Smart Chain',
    rpcUrl: process.env.NEXT_PUBLIC_BSC_RPC || 'https://bsc-dataseed.binance.org',
    explorer: 'https://bscscan.com',
    nativeCurrency: { name: 'BNB', symbol: 'BNB', decimals: 18 },
    contracts: {
      vault: '0x0000000000000000000000000000000000000000',
      gridStrategy: '0x0000000000000000000000000000000000000000',
      copyTrading: '0x0000000000000000000000000000000000000000',
    },
  },
} as const;

export type ChainKey = keyof typeof SUPPORTED_CHAINS;

export const CHAIN_NAMES = {
  42161: 'Arbitrum One',
  10: 'Optimism',
  137: 'Polygon',
  56: 'BNB Smart Chain',
} as const;
