# QuantTrade Smart Contracts

智能合约代码，基于 Solidity 0.8.20 开发。

## 核心合约

### 1. Vault.sol - 资金托管合约

管理用户存入的资金，支持：
- 多代币存取
- 策略授权机制
- 受信任策略管理
- 安全转账

### 2. GridStrategy.sol - 网格策略合约

实现网格交易策略，支持：
- 经典网格交易
- 趋势跟随模式
- 参数动态调整
- 交易历史记录

### 3. CopyTradingManager.sol - 跟单管理合约

社交跟单功能，支持：
- 三种跟单模式（镜像/策略复制/智能分配）
- 风控限制检查
- 策略师验证机制
- 收益统计

## 开发环境设置

### 安装依赖

```bash
npm install --save-dev hardhat @openzeppelin/contracts
```

### 编译合约

```bash
npx hardhat compile
```

### 运行测试

```bash
npx hardhat test
```

### 部署脚本

```javascript
// scripts/deploy.js
const { ethers } = require("hardhat");

async function main() {
  const Vault = await ethers.getContractFactory("Vault");
  const vault = await Vault.deploy();
  await vault.deployed();
  console.log("Vault deployed to:", vault.address);

  const GridStrategy = await ethers.getContractFactory("GridStrategy");
  const strategy = await GridStrategy.deploy(
    {
      tokenA: "0x...",
      tokenB: "0x...",
      gridCount: 10,
      priceLower: ethers.utils.parseEther("2000"),
      priceUpper: ethers.utils.parseEther("3000"),
      amountPerGrid: ethers.utils.parseEther("0.1"),
      isTrendFollowing: true
    },
    vault.address,
    "0x...", // Price Oracle
    "0x..."  // DEX Router
  );
  await strategy.deployed();
  console.log("GridStrategy deployed to:", strategy.address);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
```

## 安全注意事项

1. **访问控制**: 使用 OpenZeppelin 的 Ownable 和 AccessControl
2. **重入攻击防护**: 使用 ReentrancyGuard
3. **紧急暂停**: 实现了 Pausable 功能
4. **安全转账**: 使用 SafeERC20
5. **参数验证**: 所有输入参数都经过严格验证

## 审计建议

在主网部署前，建议进行以下审计：

1. 智能合约安全审计
2. 代码审查
3. 测试覆盖率检查
4. Gas 优化分析

## 部署网络

- Arbitrum One
- Optimism
- Polygon
- BSC

## 许可证

MIT
