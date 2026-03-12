import type { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './globals.css';
import { Providers } from './providers';
import { Header } from '@/components/layout/Header';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'QuantTrade Web3 - 多链量化交易平台',
  description: '基于Web3的多链量化交易平台，支持网格交易机器人、社交跟单、资产管理看板功能',
  keywords: ['Web3', '量化交易', '网格交易', 'DeFi', '加密货币', '跟单交易'],
};

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="zh-CN">
      <body className={inter.className}>
        <Providers>
          <div className="min-h-screen flex flex-col">
            <Header />
            <main className="flex-1">
              {children}
            </main>
            <footer className="border-t border-dark-700 py-6">
              <div className="container mx-auto px-4 text-center text-sm text-gray-500">
                <p>© 2024 QuantTrade Web3. All rights reserved.</p>
              </div>
            </footer>
          </div>
        </Providers>
      </body>
    </html>
  );
}
