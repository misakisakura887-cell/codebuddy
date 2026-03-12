'use client';

import Link from 'next/link';
import { WalletConnect } from '@/components/wallet/WalletConnect';
import { useAccount } from 'wagmi';
import { 
  Home, 
  BarChart3, 
  Settings, 
  DollarSign, 
  Users 
} from 'lucide-react';

const navigation = [
  { name: 'Dashboard', href: '/dashboard', icon: Home },
  { name: 'Strategies', href: '/strategies', icon: Settings },
  { name: 'Portfolio', href: '/portfolio', icon: BarChart3 },
  { name: 'Copy Trading', href: '/copy-trading', icon: Users },
  { name: 'Leaderboard', href: '/leaderboard', icon: DollarSign },
];

export function Header() {
  const { isConnected } = useAccount();

  return (
    <header className="sticky top-0 z-50 w-full border-b border-dark-700 bg-dark-900/80 backdrop-blur-xl">
      <div className="container mx-auto px-4">
        <div className="flex h-16 items-center justify-between">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2">
            <div className="w-10 h-10 bg-gradient-to-br from-primary-500 to-purple-600 rounded-lg flex items-center justify-center">
              <span className="text-white font-bold text-xl">Q</span>
            </div>
            <span className="text-xl font-bold text-white">QuantTrade</span>
          </Link>

          {/* Navigation */}
          {isConnected && (
            <nav className="hidden md:flex items-center gap-1">
              {navigation.map((item) => (
                <Link
                  key={item.name}
                  href={item.href}
                  className="flex items-center gap-2 px-4 py-2 text-sm font-medium text-gray-300 hover:text-white hover:bg-dark-700 rounded-lg transition-colors"
                >
                  <item.icon className="w-5 h-5" />
                  {item.name}
                </Link>
              ))}
            </nav>
          )}

          {/* Wallet Connect */}
          <WalletConnect />
        </div>
      </div>
    </header>
  );
}
