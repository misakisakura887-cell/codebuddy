import { create } from 'zustand';

interface WalletState {
  address: string | null;
  chainId: number | null;
  isConnected: boolean;
  isConnecting: boolean;
  balance: string;
  setAddress: (address: string | null) => void;
  setChainId: (chainId: number | null) => void;
  setConnected: (isConnected: boolean) => void;
  setConnecting: (isConnecting: boolean) => void;
  setBalance: (balance: string) => void;
  reset: () => void;
}

export const useWalletStore = create<WalletState>((set) => ({
  address: null,
  chainId: null,
  isConnected: false,
  isConnecting: false,
  balance: '0',
  setAddress: (address) => set({ address }),
  setChainId: (chainId) => set({ chainId }),
  setConnected: (isConnected) => set({ isConnected }),
  setConnecting: (isConnecting) => set({ isConnecting }),
  setBalance: (balance) => set({ balance }),
  reset: () =>
    set({
      address: null,
      chainId: null,
      isConnected: false,
      isConnecting: false,
      balance: '0',
    }),
}));
