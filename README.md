# QuantTrade Web3 - 多链量化交易平台

基于 Web3 的多链量化交易平台，支持网格交易机器人、社交跟单、资产管理看板功能。

## 项目概览

本项目是一个完整的 Web3 量化交易平台，包含前端、后端和智能合约三大部分。

### 核心功能

- **网格交易机器人**: 趋势+网格混合策略，自动执行交易
- **社交跟单**: 支持镜像、策略复制、智能分配、风险控制四种跟单模式
- **资产管理**: 多链资产汇总、实时收益统计、历史记录查询
- **多链支持**: Arbitrum、Optimism、Polygon、BSC

## 技术栈

| 组件 | 技术选型 |
|------|---------|
| 前端 | Next.js 14 + wagmi + ethers.js |
| 后端 | NestJS + TypeScript |
| 数据库 | PostgreSQL + TimescaleDB + Redis |
| 智能合约 | Solidity 0.8.20 + OpenZeppelin |
| 区块链 | Arbitrum, Optimism, Polygon, BSC |

## 项目结构

```
quant-trading-platform/
├── frontend/           # Next.js 前端应用
│   ├── app/           # App Router 页面
│   ├── components/    # React 组件
│   ├── hooks/         # 自定义 Hooks
│   ├── lib/           # 工具库
│   └── store/         # Zustand 状态管理
│
├── backend/           # NestJS 后端服务
│   ├── src/
│   │   ├── modules/   # 业务模块
│   │   ├── common/    # 公共组件
│   │   └── config/    # 配置文件
│   └── test/          # 测试文件
│
└── contracts/         # 智能合约
    ├── core/          # 核心合约
    ├── interfaces/    # 接口定义
    └── periphery/     # 外围合约
```

## 快速开始

### 前端

```bash
cd frontend
npm install
cp .env.example .env.local
npm run dev
```

访问 http://localhost:3000

### 后端

```bash
cd backend
npm install
cp .env.example .env
npm run start:dev
```

访问 http://localhost:3001/api

### 智能合约

```bash
cd contracts
npm install
npx hardhat compile
npx hardhat test
```

## 核心合约

### Vault.sol - 资金托管

- 多代币存取
- 策略授权机制
- 安全转账

### GridStrategy.sol - 网格策略

- 经典网格交易
- 趋势跟随模式
- 动态参数调整

### CopyTradingManager.sol - 跟单管理

- 三种跟单模式
- 风控限制
- 策略师验证

## 开发进度

- [x] 第一阶段: 基础设施搭建
  - [x] 前端项目初始化
  - [x] 后端项目初始化
  - [x] 智能合约开发
  - [x] 钱包连接功能
  - [x] 基础认证系统

- [ ] 第二阶段: 网格交易机器人
  - [ ] 网格配置表单
  - [ ] 策略管理页面
  - [ ] 价格订阅服务
  - [ ] 交易执行引擎

- [ ] 第三阶段: 资产管理看板
- [ ] 第四阶段: 社交交易功能
- [ ] 第五阶段: 优化与上线

## 安全注意事项

- 请勿在代码中硬编码私钥或助记词
- 所有敏感信息通过环境变量配置
- 主网使用前在测试网充分测试
- 建议进行智能合约安全审计

## 许可证

MIT

## 联系方式

如有问题或建议，请提交 Issue 或 Pull Request。
