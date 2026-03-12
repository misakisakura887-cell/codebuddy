# QuantTrade Web3 - 多链量化交易平台

基于 Web3 的多链量化交易平台，支持网格交易机器人、社交跟单、资产管理看板功能。

## 技术栈

- **前端框架**: Next.js 14 (App Router)
- **Web3库**: wagmi v2 + ethers.js v6
- **钱包连接**: RainbowKit
- **状态管理**: Zustand
- **样式**: Tailwind CSS
- **类型**: TypeScript

## 支持的区块链

- Arbitrum One
- Optimism
- Polygon
- BSC (BNB Smart Chain)

## 核心功能

### 1. 钱包连接系统
- MetaMask, WalletConnect, Coinbase Wallet 支持
- 多链切换
- 钱包签名认证 (SIWE 标准)
- 实时余额显示

### 2. 网格交易机器人
- 趋势+网格混合策略
- 自动执行交易
- 参数可配置
- 风险控制

### 3. 资产管理看板
- 多链资产汇总
- 实时收益统计
- 历史交易记录
- 可视化图表

### 4. 社交交易功能
- 策略发布市场
- 四种跟单模式
- 排行榜系统
- 收益分成

## 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 配置环境变量

复制 `.env.example` 到 `.env.local` 并填写必要的配置：

```bash
cp .env.example .env.local
```

需要配置的环境变量：
- `NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID`: WalletConnect 项目ID
- `NEXT_PUBLIC_ARBITRUM_RPC`: Arbitrum RPC端点
- `NEXT_PUBLIC_OPTIMISM_RPC`: Optimism RPC端点
- `NEXT_PUBLIC_POLYGON_RPC`: Polygon RPC端点
- `NEXT_PUBLIC_BSC_RPC`: BSC RPC端点

### 3. 启动开发服务器

```bash
npm run dev
```

访问 http://localhost:3000

## 项目结构

```
frontend/
├── app/                     # Next.js App Router
│   ├── (auth)/             # 认证相关路由组
│   ├── (dashboard)/        # 仪表盘路由组
│   ├── (trading)/          # 交易相关路由组
│   ├── (social)/           # 社交交易路由组
│   ├── layout.tsx          # 根布局
│   ├── page.tsx            # 首页
│   ├── providers.tsx       # wagmi & RainbowKit providers
│   └── globals.css         # 全局样式
├── components/             # 组件库
│   ├── ui/                 # 基础UI组件
│   ├── wallet/             # 钱包相关组件
│   ├── trading/            # 交易相关组件
│   ├── portfolio/          # 资产相关组件
│   ├── social/             # 社交交易组件
│   └── layout/             # 布局组件
├── hooks/                  # 自定义Hooks
├── lib/                    # 工具库
│   ├── wagmi.ts           # wagmi配置
│   ├── constants/         # 常量定义
│   └── utils/             # 工具函数
├── store/                  # Zustand状态管理
├── types/                  # TypeScript类型定义
└── public/                 # 静态资源
```

## 开发路线图

### 第一阶段: 基础设施 ✅
- [x] 项目初始化
- [x] wagmi + RainbowKit 配置
- [x] 钱包连接组件
- [x] 基础布局组件
- [x] Dashboard 页面

### 第二阶段: 网格交易机器人 (进行中)
- [ ] 网格配置表单组件
- [ ] 策略列表页面
- [ ] 策略详情页面
- [ ] 价格图表组件
- [ ] 持仓监控组件

### 第三阶段: 资产管理看板
- [ ] 资产概览页面
- [ ] 收益图表组件
- [ ] 历史记录页面

### 第四阶段: 社交交易功能
- [ ] 策略师市场页面
- [ ] 跟单配置弹窗
- [ ] 排行榜页面

### 第五阶段: 优化与上线
- [ ] 性能优化
- [ ] 安全加固
- [ ] 生产部署

## 后端API

后端服务使用 NestJS 开发，提供以下API：

- 用户认证 API
- 策略管理 API
- 交易执行 API
- 资产查询 API
- 跟单管理 API

## 智能合约

核心合约包括：

- **Vault.sol**: 资金托管合约
- **GridStrategy.sol**: 网格策略合约
- **CopyTradingManager.sol**: 跟单管理合约

## 安全注意事项

- 请勿在代码中硬编码私钥或助记词
- 所有敏感信息应通过环境变量配置
- 在主网使用前务必在测试网充分测试
- 建议进行智能合约安全审计

## 许可证

MIT

## 联系方式

如有问题或建议，请提交 Issue 或 Pull Request。
