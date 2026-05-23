# Debot Open Skills

[中文](#中文) | [English](#english)

## 中文

`ai-trading-skills` 是 Debot 面向外部开放的 Skills 能力集合。这个项目会持续沉淀 Debot 在链上数据、AI 信号、交易执行和自动化工作流中的能力，让 AI Agent、开发者工具和自动化系统可以用统一的 Skill 描述来调用 Debot。

当前版本主要开放链上交易相关能力。后续 Debot 会开放更多实时数据能力，包括但不限于行情数据、链上监控数据、AI 信号数据、策略辅助数据，以及更完整的交易执行能力。

## 已支持 Skills

### `debot-trade`

路径：`skills/trade/skills.md`

`debot-trade` 提供基于 `debot-trade-cli` 的服务端链上交易能力，不依赖浏览器钱包，适合在 AI Agent、自动化脚本或服务端环境中执行交易相关操作。

#### 核心能力

| 能力 | 说明 |
| --- | --- |
| 钱包列表 | 查询当前 API Key 绑定的所有钱包地址 |
| 链上交易 | 支持买入、卖出、Swap 任意链上 Token |
| 按比例卖出 | 支持按当前持仓百分比卖出 Token |
| 自定义交易签名与广播 | 支持签名并广播 EVM calldata 或 Solana 序列化交易消息 |
| 多链支持 | 支持 Solana、Ethereum、BNB Chain、Base、XLayer、Monad |
| 多 DEX 支持 | 集成 Uniswap、PancakeSwap、PumpFun、FourMeme、Flap 等 DEX 或交易场景 |

#### CLI 命令

| 命令 | 用途 |
| --- | --- |
| `wallets` | 列出当前账号可用钱包 |
| `trade` | 执行买入、卖出、Swap 等交易 |
| `sign-tx` | 签名并广播自定义交易 |

#### 适用场景

- AI Agent 根据用户确认后的指令执行链上买入、卖出或 Swap
- 在服务端环境中管理 Debot 钱包并发起交易
- 对接 Solana 或 EVM 链上的自定义交易签名与广播流程
- 构建交易 Bot、自动化交易工具、策略执行器或 AI 交易助手

#### 安全约束

`debot-trade` 的 Skill 文档内置了交易安全规则：

- 只能使用 `wallets` 返回的钱包地址执行交易
- 执行交易前必须确认链、钱包、Token 地址和交易数量
- 自定义交易签名需要识别高风险参数，并在必要时二次确认
- 交易失败后不自动重试，需要把错误信息返回给用户确认下一步

## 未来开放方向

Debot 会逐步开放更多 Skills，让外部系统可以组合使用 Debot 的数据、信号和交易能力。

计划中的能力包括：

- 实时行情数据：Token 价格、K 线、成交、流动性和市场状态
- 链上监控数据：钱包行为、资金流、聪明钱、合约交互和新币动态
- AI 信号数据：买卖信号、风险提示、热点发现和策略辅助判断
- 交易增强能力：更丰富的路由、风控、订单管理和跨链交易能力
- 自动化工作流：围绕数据监听、信号触发、交易执行和结果追踪的完整链路

## 使用方式

每个 Skill 都会在 `skills/` 目录下提供独立说明文档，包含能力描述、调用方式、参数约束、示例和安全规则。

当前可查看：

- `skills/trade/skills.md`：Debot 链上交易 Skill

## 开发者入口

Debot Developer Center:

https://debot.ai/ws/debot_developer_center/

---

[中文](#中文) | [English](#english)

## English

`ai-trading-skills` is the public Skills capability collection from Debot. This project exposes Debot's capabilities around on-chain data, AI signals, trading execution, and automated workflows through unified Skill descriptions that can be used by AI agents, developer tools, and automation systems.

The current release focuses on on-chain trading capabilities. Debot will continue to open more real-time data capabilities in the future, including market data, on-chain monitoring data, AI signal data, strategy assistance data, and more complete trading execution capabilities.

## Supported Skills

### `debot-trade`

Path: `skills/trade/skills.md`

`debot-trade` provides server-side on-chain trading through `debot-trade-cli`. It does not require a browser wallet and is suitable for AI agents, automation scripts, and server-side trading workflows.

#### Core Capabilities

| Capability | Description |
| --- | --- |
| Wallet list | List all wallet addresses bound to the current API key |
| On-chain trading | Buy, sell, and swap any on-chain token |
| Percentage sell | Sell a percentage of the current token holdings |
| Custom transaction signing and broadcast | Sign and broadcast EVM calldata or Solana serialized transaction messages |
| Multi-chain support | Supports Solana, Ethereum, BNB Chain, Base, XLayer, and Monad |
| Multi-DEX support | Integrates with Uniswap, PancakeSwap, PumpFun, FourMeme, Flap, and other DEX or trading scenarios |

#### CLI Commands

| Command | Purpose |
| --- | --- |
| `wallets` | List available wallets for the current account |
| `trade` | Execute buy, sell, and swap transactions |
| `sign-tx` | Sign and broadcast custom transactions |

#### Use Cases

- Let AI agents execute on-chain buy, sell, or swap transactions after explicit user confirmation
- Manage Debot wallets and initiate trades in server-side environments
- Integrate custom transaction signing and broadcasting for Solana or EVM chains
- Build trading bots, automated trading tools, strategy executors, or AI trading assistants

#### Safety Rules

The `debot-trade` Skill document includes built-in trading safety rules:

- Trades can only use wallet addresses returned by `wallets`
- Chain, wallet, token addresses, and trading amount must be confirmed before execution
- Custom transaction signing must identify risky parameters and request additional confirmation when needed
- Failed transactions must not be retried automatically; the error should be returned to the user for confirmation of the next step

## Future Roadmap

Debot will gradually open more Skills so external systems can combine Debot's data, signals, and trading capabilities.

Planned capabilities include:

- Real-time market data: token prices, candlesticks, trades, liquidity, and market status
- On-chain monitoring data: wallet behavior, fund flows, smart money, contract interactions, and new token activity
- AI signal data: buy/sell signals, risk alerts, trend discovery, and strategy assistance
- Enhanced trading capabilities: richer routing, risk control, order management, and cross-chain trading
- Automated workflows: full workflows around data monitoring, signal triggers, trading execution, and result tracking

## Usage

Each Skill provides its own documentation under the `skills/` directory, including capability descriptions, invocation methods, parameter constraints, examples, and safety rules.

Currently available:

- `skills/trade/skills.md`: Debot on-chain trading Skill

## Developer Portal

Debot Developer Center:

https://debot.ai/ws/debot_developer_center/
