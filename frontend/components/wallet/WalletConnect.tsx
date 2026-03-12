'use client';

import { ConnectButton } from '@rainbow-me/rainbowkit';
import { useAccount, useBalance, useDisconnect } from 'wagmi';
import { useEffect } from 'react';
import { useWalletStore } from '@/store/useWalletStore';
import { formatBalance, formatAddress } from '@/lib/utils';

export function WalletConnect() {
  const { address, isConnected } = useAccount();
  const { data: balanceData } = useBalance({
    address: address,
  });
  const { disconnect } = useDisconnect();
  
  const {
    setAddress,
    setConnected,
    setBalance,
  } = useWalletStore();

  useEffect(() => {
    setAddress(address || null);
    setConnected(isConnected);
    if (balanceData) {
      setBalance(balanceData.formatted);
    }
  }, [address, isConnected, balanceData, setAddress, setConnected, setBalance]);

  return (
    <ConnectButton.Custom>
      {({
        account,
        chain,
        openAccountModal,
        openChainModal,
        openConnectModal,
        authenticationStatus,
        mounted,
      }) => {
        const ready = mounted && authenticationStatus !== 'loading';
        const connected =
          ready && account && chain && (!authenticationStatus || authenticationStatus === 'authenticated');

        if (!connected) {
          return (
            <button
              onClick={openConnectModal}
              className="bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 text-white font-semibold py-2.5 px-6 rounded-lg transition-all duration-200 shadow-lg hover:shadow-primary-500/25"
            >
              Connect Wallet
            </button>
          );
        }

        if (chain.unsupported) {
          return (
            <button
              onClick={openChainModal}
              className="bg-red-500 hover:bg-red-600 text-white font-semibold py-2.5 px-6 rounded-lg transition-all duration-200"
            >
              Wrong Network
            </button>
          );
        }

        return (
          <div className="flex items-center gap-3">
            <button
              onClick={openChainModal}
              className="flex items-center gap-2 bg-dark-700 hover:bg-dark-600 px-4 py-2 rounded-lg transition-colors"
            >
              {chain.hasIcon && (
                <div
                  className="w-5 h-5 rounded-full overflow-hidden"
                  style={{
                    background: chain.iconBackground,
                  }}
                >
                  {chain.iconUrl && (
                    <img
                      alt={chain.name ?? 'Chain icon'}
                      src={chain.iconUrl}
                      className="w-full h-full object-cover"
                    />
                  )}
                </div>
              )}
              <span className="text-sm font-medium text-white">{chain.name}</span>
            </button>

            <button
              onClick={openAccountModal}
              className="flex items-center gap-2 bg-dark-700 hover:bg-dark-600 px-4 py-2 rounded-lg transition-colors"
            >
              <div className="w-2 h-2 rounded-full bg-green-500"></div>
              <span className="text-sm font-medium text-white">
                {formatAddress(account.address, 4)}
              </span>
              {balanceData && (
                <span className="text-xs text-gray-400">
                  {formatBalance(balanceData.formatted, 4)} {balanceData.symbol}
                </span>
              )}
            </button>
          </div>
        );
      }}
    </ConnectButton.Custom>
  );
}
