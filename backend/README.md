# QuantTrade Backend - NestJS API

基于 NestJS 的量化交易平台后端服务。

## 技术栈

- **框架**: NestJS 10
- **数据库**: PostgreSQL + TypeORM
- **缓存**: Redis
- **认证**: JWT + 钱包签名
- **任务调度**: @nestjs/schedule
- **WebSocket**: @nestjs/websockets

## 快速开始

### 1. 安装依赖

```bash
npm install
```

### 2. 配置环境变量

复制 `.env.example` 到 `.env` 并填写必要的配置：

```bash
cp .env.example .env
```

### 3. 启动数据库

确保 PostgreSQL 和 Redis 已启动：

```bash
# PostgreSQL (Docker)
docker run --name postgres -e POSTGRES_PASSWORD=password -p 5432:5432 -d postgres

# Redis (Docker)
docker run --name redis -p 6379:6379 -d redis
```

### 4. 启动开发服务器

```bash
npm run start:dev
```

访问 http://localhost:3001/api

## API 端点

### 认证 API

| 方法 | 端点 | 描述 |
|------|------|------|
| POST | `/api/auth/nonce` | 获取签名 nonce |
| POST | `/api/auth/verify` | 验证签名并登录 |
| POST | `/api/auth/refresh` | 刷新 token |
| GET | `/api/auth/me` | 获取当前用户 |

### 用户 API

| 方法 | 端点 | 描述 |
|------|------|------|
| GET | `/api/users/me` | 获取当前用户信息 |
| PUT | `/api/users/me` | 更新用户信息 |
| GET | `/api/users/strategists` | 获取热门策略师 |

## 项目结构

```
backend/
├── src/
│   ├── main.ts                    # 入口文件
│   ├── app.module.ts              # 根模块
│   ├── common/                    # 公共模块
│   │   ├── decorators/           # 自定义装饰器
│   │   ├── guards/               # 守卫
│   │   ├── filters/              # 过滤器
│   │   └── interceptors/         # 拦截器
│   ├── modules/                  # 业务模块
│   │   ├── auth/                 # 认证模块
│   │   ├── user/                 # 用户模块
│   │   ├── strategy/             # 策略模块
│   │   ├── trading/              # 交易模块
│   │   ├── portfolio/            # 资产模块
│   │   ├── copy-trading/         # 跟单模块
│   │   ├── price/                # 价格服务
│   │   ├── blockchain/           # 区块链适配
│   │   ├── risk/                 # 风控模块
│   │   └── notification/         # 通知模块
│   ├── config/                   # 配置文件
│   └── database/                 # 数据库
│       ├── migrations/           # 迁移文件
│       └── seeds/                # 种子数据
└── test/                         # 测试目录
```

## 数据库模型

### User (用户)

| 字段 | 类型 | 描述 |
|------|------|------|
| id | UUID | 主键 |
| walletAddress | String | 钱包地址 |
| username | String | 用户名 |
| isStrategist | Boolean | 是否为策略师 |
| strategistScore | Decimal | 策略师评分 |
| totalFollowers | Integer | 跟随者数量 |

## 开发指南

### 运行测试

```bash
# 单元测试
npm run test

# e2e 测试
npm run test:e2e

# 测试覆盖率
npm run test:cov
```

### 代码规范

```bash
# 格式化代码
npm run format

# 代码检查
npm run lint
```

## 许可证

MIT
