'use client';

import { useAccount } from 'wagmi';
import { useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { Card, CardHeader, CardTitle, CardContent } from '@/components/ui/card';
import { formatUSD } from '@/lib/utils';

export default function DashboardPage() {
  const { isConnected, address } = useAccount();
  const router = useRouter();

  useEffect(() => {
    if (!isConnected) {
      router.push('/');
    }
  }, [isConnected, router]);

  if (!isConnected) {
    return null;
  }

  const stats = [
    { label: '总资产', value: '$12,345.67', change: '+5.23%', positive: true },
    { label: '活跃策略', value: '3', change: null, positive: true },
    { label: '总收益', value: '+$1,234.56', change: '+12.34%', positive: true },
    { label: '跟单人数', value: '28', change: '+3', positive: true },
  ];

  const recentTrades = [
    { id: 1, pair: 'ETH/USDT', side: 'BUY', amount: '0.5 ETH', price: '$2,345.67', profit: '+$12.34', time: '2分钟前' },
    { id: 2, pair: 'BTC/USDT', side: 'SELL', amount: '0.1 BTC', price: '$43,567.89', profit: '-$8.45', time: '15分钟前' },
    { id: 3, pair: 'ETH/USDT', side: 'BUY', amount: '1.2 ETH', price: '$2,340.12', profit: '+$23.56', time: '1小时前' },
  ];

  return (
    <div className="container mx-auto px-4 py-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-white mb-2">仪表盘</h1>
        <p className="text-gray-400">欢迎回来，查看您的资产和策略概览</p>
      </div>

      {/* Stats Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
        {stats.map((stat, index) => (
          <Card key={index} hover>
            <CardHeader>
              <p className="text-sm text-gray-400">{stat.label}</p>
            </CardHeader>
            <CardContent>
              <div className="flex items-end justify-between">
                <p className="text-2xl font-bold text-white">{stat.value}</p>
                {stat.change && (
                  <span className={`text-sm font-medium ${stat.positive ? 'text-green-500' : 'text-red-500'}`}>
                    {stat.change}
                  </span>
                )}
              </div>
            </CardContent>
          </Card>
        ))}
      </div>

      {/* Main Content */}
      <div className="grid lg:grid-cols-3 gap-6">
        {/* Recent Trades */}
        <div className="lg:col-span-2">
          <Card>
            <CardHeader>
              <CardTitle>最近交易</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                {recentTrades.map((trade) => (
                  <div
                    key={trade.id}
                    className="flex items-center justify-between py-3 border-b border-dark-600 last:border-0"
                  >
                    <div className="flex items-center gap-4">
                      <div className={`w-12 h-12 rounded-lg flex items-center justify-center ${
                        trade.side === 'BUY' ? 'bg-green-500/20' : 'bg-red-500/20'
                      }`}>
                        <span className={`font-semibold ${trade.side === 'BUY' ? 'text-green-500' : 'text-red-500'}`}>
                          {trade.side}
                        </span>
                      </div>
                      <div>
                        <p className="font-medium text-white">{trade.pair}</p>
                        <p className="text-sm text-gray-400">{trade.amount}</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="font-medium text-white">{trade.price}</p>
                      <p className={`text-sm ${trade.profit.startsWith('+') ? 'text-green-500' : 'text-red-500'}`}>
                        {trade.profit}
                      </p>
                    </div>
                    <div className="text-right">
                      <p className="text-sm text-gray-400">{trade.time}</p>
                    </div>
                  </div>
                ))}
              </div>
            </CardContent>
          </Card>
        </div>

        {/* Quick Actions */}
        <div>
          <Card>
            <CardHeader>
              <CardTitle>快速操作</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-3">
                <button className="w-full bg-gradient-to-r from-primary-500 to-primary-600 hover:from-primary-600 hover:to-primary-700 text-white font-semibold py-3 px-4 rounded-lg transition-all">
                  创建新策略
                </button>
                <button className="w-full bg-dark-600 hover:bg-dark-500 text-white font-semibold py-3 px-4 rounded-lg transition-all border border-dark-500">
                  存入资金
                </button>
                <button className="w-full bg-dark-600 hover:bg-dark-500 text-white font-semibold py-3 px-4 rounded-lg transition-all border border-dark-500">
                  浏览策略市场
                </button>
              </div>
            </CardContent>
          </Card>

          {/* Active Strategies */}
          <Card className="mt-6">
            <CardHeader>
              <CardTitle>活跃策略</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="font-medium text-white">ETH Grid Bot</p>
                    <p className="text-sm text-gray-400">Arbitrum</p>
                  </div>
                  <div className="text-right">
                    <p className="font-medium text-green-500">+12.34%</p>
                    <div className="w-2 h-2 bg-green-500 rounded-full inline-block"></div>
                  </div>
                </div>
                <div className="flex items-center justify-between">
                  <div>
                    <p className="font-medium text-white">BTC Grid Bot</p>
                    <p className="text-sm text-gray-400">Optimism</p>
                  </div>
                  <div className="text-right">
                    <p className="font-medium text-green-500">+8.56%</p>
                    <div className="w-2 h-2 bg-green-500 rounded-full inline-block"></div>
                  </div>
                </div>
              </div>
            </CardContent>
          </Card>
        </div>
      </div>
    </div>
  );
}
