# Debot Open Skills

[中文](README.md) | [English](README.en.md)

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
| Multi-chain support | Supports Solana, Ethereum, BNB Chain, Base, XLayer, Monad, HyperEVM, and Robinhood Chain |
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
