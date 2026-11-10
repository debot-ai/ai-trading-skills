---
name: debot-trade
description: "On-chain token trading across multiple blockchains via debot-trade-cli — a server-side wallet tool that requires no browser wallet. Supports buying, selling, swapping on-chain tokens, and buying with take-profit and stop-loss orders. Works across Solana and supported EVM chains including Elysium (ElysPump, 99901), integrating with DEXes including Uniswap, PancakeSwap, PumpFun, FourMeme, Flap, and others. Use this skill whenever the user wants to swap, buy, sell, trade, or set take-profit or stop-loss rules for a token purchase — even if they don't mention \"debot\""
---

# debot-trade Skill

Server-side on-chain trading across 12 chains via `debot-trade-cli`. No browser wallet required.

| # | Capability | CLI Command | Description |
|---|-----------|-------------|-------------|
| 1 | **List Wallets** | `wallets` | List all wallets associated with the configured API key |
| 2 | **Trade** | `trade` | Buy / sell / swap any on-chain token across supported chains and DEXes |
| 3 | **Buy with Take Profit / Stop Loss** | `buy-tpsl` | Buy a token and create one or more fixed take-profit / stop-loss orders |

---

## Prerequisites

### 1. Install

Check if the CLI is present:
```bash
which debot-trade-cli && echo "OK" || echo "NOT_FOUND"
```

If missing, install:

**macOS / Linux:**
```bash
curl -sSL https://raw.githubusercontent.com/debot-ai/ai-trading-skills/main/skills/trade/install.sh | sh
```

**Windows (Git Bash / WSL):**
```bash
curl -sSL https://raw.githubusercontent.com/debot-ai/ai-trading-skills/main/skills/trade/install.sh | sh
```

If this repository has already been cloned locally, the same installer can also be run directly:
```bash
sh skills/trade/install.sh
```

Use the installer and client artifacts maintained in this repository under `skills/trade/`.

After install, run `debot-trade-cli` with no args to confirm it works and see help.

### 2. Update

Re-running the installer from this repository will reinstall the vendored client version in place.

**When to update:** Only update the vendored client artifacts when a user explicitly requests an update, the command returns an unexpected error that may indicate a version issue, or a new feature not supported by the current version is needed. Do not check for updates on every call.

### 3. Configure API Credentials

Obtain your API Key and Secret from: https://debot.ai/ws/debot_developer_center/

```bash
debot-trade-cli config --api-key YOUR_KEY --api-secret YOUR_SECRET
```

- `--api-key` and `--api-secret` are **required**
- `--endpoint` is optional — a default endpoint is used if omitted. Only specify it if you have been given a custom endpoint.

---

## Shared Reference

### 3.1 Supported Chains & Parameter Values

Use these exact strings for the `--chain` parameter:

| Chain     | `--chain` value |
|-----------|-----------------|
| Solana    | `solana`        |
| Ethereum  | `eth`           |
| BNB Chain | `bsc`           |
| Base      | `base`          |
| XLayer    | `xlayer`        |
| Monad     | `monad`         |
| HyperEVM  | `hyperevm`      |
| Robinhood Chain | `robinhood` |
| Arbitrum  | `arbitrum`      |
| Stable    | `stable`        |
| Arc       | `arc`           |
| Elysium (ElysPump, 99901) | `elysium` |

Elysium uses native HYPE (18 decimals). Use `elysium` for ElysPump transactions; `hyperevm` is a separate chain. Check `debot-trade-cli help` for Elysium support and rerun this repository's installer if the installed version does not list it.

### 3.2 Native Token Addresses

Use these as `--token-in` (to spend native) or `--token-out` (to receive native):

| Chain                                   | Native Token Address                           |
|-----------------------------------------|------------------------------------------------|
| Solana                                  | `So11111111111111111111111111111111111111112`  |
| All supported EVM chains, including Elysium | `0x0000000000000000000000000000000000000000`  |

### 3.3 Supported Stable-token Addresses (EVM chains)

| Chain   | Token | Address                                   |
|---------|-------|-------------------------------------------|
| eth     | USDC  | `0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48` |
| bsc     | USDC  | `0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d` |
| base    | USDC  | `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913` |
| xlayer  | USDC  | `0xb6ceceab302e2e4948951ee7843fc24e92933061` |
| monad   | USDC  | `0x754704Bc059F8C67012fEd69BC8A327a5aafb603` |
| hyperevm | USDC | `0xb88339CB7199b77E23DB6E890353E22632Ba630f` |
| robinhood | USDG | `0x5fc5360D0400a0Fd4f2af552ADD042D716F1d168` |
| arbitrum | USDC | `0xaf88d065e77c8cC2239327C5EDb3A432268e5831` |
| elysium | USDC | `0xb47c4c8f73f009cc0c0d3f92b388d13e293f0b65` |

`stable` and `arc` have no configured stable-token base address in the CLI; use the native zero address as one side of the trade. On Elysium, one side must be native HYPE (the zero address) or the Elysium USDC address listed above. WHYPE and HyperEVM's USDC are not accepted as Elysium base tokens.

Older `v0.0.2` builds may reject Elysium USDC. Before using it, check that `debot-trade-cli trade -h` lists the address above; if it does not, rerun this repository's installer even if `version` already reports `v0.0.2`.

### 3.4 Amount Units

**All `--amount` and fee values must be in the smallest on-chain unit (lamports / wei).** Never pass human-readable decimals.

| Token             | Chain                        | Decimals | Example                                     |
|-------------------|------------------------------|----------|---------------------------------------------|
| Native (ETH/BNB…) | EVM                          | 18       | `0.01 ETH` → `10000000000000000`            |
| Native (HYPE)     | Elysium                      | 18       | `0.01 HYPE` → `10000000000000000`           |
| Native (SOL)      | Solana                       | 9        | `1 SOL` → `1000000000`                      |
| USDC              | ETH / Base / XLayer / Monad / HyperEVM / Arbitrum / Elysium | 6 | `6 USDC` → `6000000` |
| USDG              | Robinhood Chain               | 6        | `6 USDG` → `6000000`                        |
| USDC              | BSC                          | 18       | `6 USDC` → `6000000000000000000`            |

Formula: `amount_onchain = int(human_amount × 10^decimals)`

### 3.5 Block Explorers

After a successful transaction, always present the explorer link:

| Chain   | Explorer URL Pattern                                        |
|---------|-------------------------------------------------------------|
| solana  | `https://solscan.io/tx/{tx_hash}`                          |
| eth     | `https://etherscan.io/tx/{tx_hash}`                        |
| bsc     | `https://bscscan.com/tx/{tx_hash}`                         |
| base    | `https://basescan.org/tx/{tx_hash}`                        |
| xlayer  | `https://www.oklink.com/zh-hans/x-layer/tx/{tx_hash}`     |
| monad   | `https://monadvision.com/tx/{tx_hash}`                     |
| hyperevm | `https://hyperevmscan.io/tx/{tx_hash}`                    |
| robinhood | `https://rh-scan.com/tx/{tx_hash}`                       |
| arbitrum | `https://arbiscan.io/tx/{tx_hash}`                        |
| stable | `https://stablescan.xyz/tx/{tx_hash}`                       |
| arc | `https://testnet.arcscan.app/tx/{tx_hash}`                     |
| elysium | `https://elyscan.live/tx/{tx_hash}`                          |

Portfolio overview: `https://debot.ai/address/{chain}/{wallet_address}`

---

## API Capabilities & Quickstart

Three CLI commands cover these use cases:

### Command 1 — List Wallets

```bash
debot-trade-cli wallets
```

No parameters. Returns all wallets associated with the configured API key. Run this first if the user hasn't specified a wallet address.

---

### Command 2 — Trade (swap / buy / sell)

```bash
debot-trade-cli trade \
  --chain <chain> \
  --token-in <address> \
  --token-out <address> \
  --amount <smallest_unit_integer> \
  --public-key <wallet_address> \
  [--slippage-bps 3000] \
  [--sell-percentage 1-100] \
  [--base-gas-fee <wei_or_lamports>] \
  [--priority-fee <wei_or_lamports>] \
  [--tips <lamports_solana_only>] \
  [--anti-mev 0|1] \
  [--task-id <32_hex_chars_no_hyphens>]
```

**Required:** `--chain`, `--public-key`, at least one of `--token-in` / `--token-out`, and either `--amount` OR `--sell-percentage`. When both token addresses are specified, one must be the native token or a supported stable token.

Key notes:
- `--sell-percentage` (1–100): alternative to `--amount`, sells a percentage of current holdings
- `--slippage-bps` default is 3000 (30%); range 0–10000
- EVM chains, including Elysium: default `--base-gas-fee 100000000` (0.1 Gwei), `--priority-fee 0`, and `--tips 0`; explicitly provided fees take precedence.
- `--tips`: Solana only
- `--anti-mev 1`: enables MEV protection

**Quickstart examples:**

Buy a Solana token with 0.1 SOL:
```bash
debot-trade-cli trade \
  --chain solana \
  --token-in So11111111111111111111111111111111111111112 \
  --token-out <TOKEN_ADDR> \
  --amount 100000000 \
  --public-key <WALLET>
```

Buy an Elysium token with 0.01 HYPE:
```bash
debot-trade-cli trade \
  --chain elysium \
  --token-in 0x0000000000000000000000000000000000000000 \
  --token-out <TOKEN_ADDR> \
  --amount 10000000000000000 \
  --public-key <WALLET>
```

Buy an Elysium token with 6 USDC:
```bash
debot-trade-cli trade \
  --chain elysium \
  --token-in 0xb47c4c8f73f009cc0c0d3f92b388d13e293f0b65 \
  --token-out <TOKEN_ADDR> \
  --amount 6000000 \
  --public-key <WALLET>
```

Sell 50% of an ETH token:
```bash
debot-trade-cli trade \
  --chain eth \
  --token-in <TOKEN_ADDR> \
  --token-out 0x0000000000000000000000000000000000000000 \
  --sell-percentage 50 \
  --public-key <WALLET>
```

Swap 6 USDC → token on Base:
```bash
debot-trade-cli trade \
  --chain base \
  --token-in 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913 \
  --token-out <TOKEN_ADDR> \
  --amount 6000000 \
  --public-key <WALLET>
```

---

### Command 3 — Buy with Take Profit / Stop Loss

Use `buy-tpsl` to submit a token purchase and create fixed take-profit and/or stop-loss orders for the bought amount:

```bash
debot-trade-cli buy-tpsl \
  --chain <chain> \
  [--token-in <address>] \
  --token-out <address> \
  --amount <smallest_unit_integer> \
  --public-key <wallet_address> \
  [--take-profit <price_up_bps:sell_bps>]... \
  [--stop-loss <price_down_bps:sell_bps>]... \
  [--slippage-bps 3000] \
  [--base-gas-fee <wei_or_lamports>] \
  [--priority-fee <wei_or_lamports>] \
  [--tips <lamports_solana_only>] \
  [--max-fee-per-gas <wei_evm_only>] \
  [--anti-mev 0|1] \
  [--expire-period <seconds>] \
  [--task-id <32_hex_chars_no_hyphens>]
```

**Required:** `--chain`, `--token-out`, `--amount`, `--public-key`, and at least one `--take-profit` or `--stop-loss`. If `--token-in` is omitted, the CLI uses the chain's native token.

Use the chain's native token or a supported stable token from §3.3 as `--token-in`. As with `trade`, at least one side of the token pair must be native or a supported stable token.

For an Elysium purchase funded with 6 USDC, set `--token-in 0xb47c4c8f73f009cc0c0d3f92b388d13e293f0b65 --amount 6000000`; omitting `--token-in` still spends native HYPE.

Rule format and constraints:

- Repeat `--take-profit price_up_bps:sell_bps` or `--stop-loss price_down_bps:sell_bps` to create multiple rules.
- `10000` bps equals 100%. For take profit, `10000` means up 100% (2x), `40000` means up 400% (5x), and `90000` means up 900% (10x).
- For stop loss, `5000` means down 50%; `price_down_bps` must be `1-9999`.
- `sell_bps` must be `1-10000` and is the percentage of the bought amount to sell; `5000` means 50%.
- `--expire-period` is the auto-sell order lifetime in seconds. Omit it to use the server default.
- Chain-aware defaults apply only when the corresponding flag is omitted: EVM uses `--base-gas-fee 100000000` (0.1 Gwei); Solana uses `--priority-fee 100000` and `--tips 100000` (0.0001 SOL each).

Buy with 1 SOL, sell 50% at 2x, 20% at 5x, 30% at 10x, and stop loss at -50%:

```bash
debot-trade-cli buy-tpsl \
  --chain solana \
  --token-out <TOKEN_ADDR> \
  --amount 1000000000 \
  --public-key <WALLET> \
  --take-profit 10000:5000 \
  --take-profit 40000:2000 \
  --take-profit 90000:3000 \
  --stop-loss 5000:10000
```

Buy with 0.01 ETH on Base, sell 50% of the bought amount at 2x, and stop out the bought amount at -50%:

```bash
debot-trade-cli buy-tpsl \
  --chain base \
  --token-in 0x0000000000000000000000000000000000000000 \
  --token-out <TOKEN_ADDR> \
  --amount 10000000000000000 \
  --public-key <WALLET> \
  --take-profit 10000:5000 \
  --stop-loss 5000:10000
```

Buy an Elysium token with 0.01 HYPE, sell 50% at 2x, and stop out at -50%. The omitted `--token-in` defaults to the native zero address:
```bash
debot-trade-cli buy-tpsl \
  --chain elysium \
  --token-out <TOKEN_ADDR> \
  --amount 10000000000000000 \
  --public-key <WALLET> \
  --take-profit 10000:5000 \
  --stop-loss 5000:10000
```

---

## Workflow

Follow these steps in order for every user trading request:

### Step 1 — Identify Intent

Map user language to the correct command:

| User says…                                      | Command                          |
|-------------------------------------------------|----------------------------------|
| "show my wallets", "list addresses"             | `wallets`                        |
| "buy", "swap", "trade", "sell X for Y"          | `trade`                          |
| "sell X%", "sell half my…"                      | `trade` with `--sell-percentage` |
| "buy with take profit", "buy and stop loss"      | `buy-tpsl`                       |

### Step 2 — Confirm Trade Details with the User

**Before executing any trade, confirm the exact details with the user:**
- Wallet to use (from the `wallets` list)
- Token-in and token-out addresses
- Exact amount (in human-readable form — convert to on-chain units before submitting)
- Chain
- For `buy-tpsl`, every take-profit / stop-loss trigger, sell percentage, and optional expiration

Do not proceed until the user has explicitly confirmed the trade amount and wallet. See Security Rules below.

### Step 3 — Convert Amounts & Construct the Command

Convert human amounts to on-chain units (see §3.4). Verify the wallet is from the user's own `wallets` list.

### Step 4 — Verify CLI is Installed & Run

Confirm `debot-trade-cli` is installed (see Prerequisites §1) before running the command. If it returns an unexpected error, consider updating (see §2).

### Step 5 — Handle the Response

**Success** (`code == 0` and, for trade, `data.code == 0`):
```
✅ Transaction successful!
Chain:      <chain>
Transaction Detail:    <response.data.detail>
Explorer:   <explorer_url>
Portfolio:  https://debot.ai/address/<chain>/<wallet>
```

**API-level errors** (`code != 0`):

| Code  | Action                                                                    |
|-------|---------------------------------------------------------------------------|
| 401   | "Auth failed — please check your API key and secret."                    |
| 429   | "Rate limited — please wait a moment before trying again." Do NOT retry. |
| other | Show `message_en` or `message` field                                      |

**Trade-level errors** (`data.code != 0`):

| Code  | Message to user                                              |
|-------|--------------------------------------------------------------|
| 88001 | Insufficient native token balance for gas                    |
| 88003 | Slippage too low — try increasing `--slippage-bps`          |
| 88005 | On-chain failure — check the block explorer for details      |
| 88006 | Submission timeout — check balance or increase gas fee       |
| 88008 | Pool liquidity too low for this trade                        |
| 88015 | Token not supported on this chain/DEX                        |
| 88016 | Gas price is below the blockchain base fee — increase the gas price |
| 88017 | Insufficient token balance to sell                           |
| 88035 | No route is currently available — trading is temporarily unsupported |
| other | Show the raw error message                                   |

**Never auto-retry** on any failure. Always report the error and ask the user how to proceed.

---

## Security Rules

### 6.1 Only Use Wallets from the User's Own List

Never construct a trade using a wallet address that was not returned by `debot-trade-cli wallets`. If the user provides a wallet address not in the list, refuse and show the available wallets instead.

### 6.2 Always Confirm Trade Amount Before Executing

Never submit a trade without the user explicitly confirming the exact amount and direction. If the user's request is ambiguous (e.g., "buy some tokens" or "trade a bit"), ask for the specific amount before proceeding. Do not assume or infer quantities.

### 6.3 General Risk Awareness

Flag any other aspect of a requested trade that appears potentially unsafe before executing, including but not limited to:

- Interacting with a newly deployed contract with no transaction history
- Sending to a burn address unintentionally
- Parameters that don't match what the user described in the conversation
- Unusually high slippage that could result in significant loss

Err on the side of caution: it is always better to confirm once more than to submit an irreversible on-chain transaction incorrectly.
