---
name: debot-trade
description: "On-chain token trading across multiple blockchains via debot-trade-cli — a server-side wallet tool that requires no browser wallet. Supports buying, selling, swapping any on-chain tokens, signing and broadcasting custom raw transactions. Works across Solana, ETH, BSC, Base, XLayer, and Monad, integrating with DEXes including Uniswap, PancakeSwap, PumpFun, FourMeme, Flap, and others. Use this skill whenever the user wants to swap, buy, sell, trade any on-chain token & sign or broadcast a custom transaction — even if they don't mention \"debot\""
---

# debot-trade Skill

Server-side on-chain trading across 6 chains via `debot-trade-cli`. No browser wallet required.

| # | Capability | CLI Command | Description |
|---|-----------|-------------|-------------|
| 1 | **List Wallets** | `wallets` | List all wallets associated with the configured API key |
| 2 | **Trade** | `trade` | Buy / sell / swap any on-chain token across supported chains and DEXes |
| 3 | **Sign & Broadcast Custom Transaction** | `sign-tx` | Sign and broadcast a custom transaction — EVM hex calldata or Solana base64 serialized message |

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
curl -sSL https://raw.githubusercontent.com/tvyvnjs/debot-trade/main/install.sh | sh
```

**Windows (PowerShell):**
```powershell
irm https://raw.githubusercontent.com/tvyvnjs/debot-trade/main/install.ps1 | iex
```

After install, run `debot-trade-cli` with no args to confirm it works and see help.

### 2. Update

Re-running the install script will update it in place

**When to update:** Only update when a user explicitly requests an update, the command returns an unexpected error that may indicate a version issue, a new feature not supported by the current version is needed, or more than 24 hours have passed since the last update. Do not check for updates on every call.

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

### 3.2 Native Token Addresses

Use these as `--token-in` (to spend native) or `--token-out` (to receive native):

| Chain                                   | Native Token Address                           |
|-----------------------------------------|------------------------------------------------|
| Solana                                  | `So11111111111111111111111111111111111111112`  |
| ETH / BSC / Base / XLayer / Monad (EVM) | `0x0000000000000000000000000000000000000000`  |

### 3.3 USDC Addresses (EVM chains)

| Chain   | USDC Address                                   |
|---------|------------------------------------------------|
| eth     | `0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48`  |
| bsc     | `0x8ac76a51cc950d9822d68b83fe1ad97b32cd580d`  |
| base    | `0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913`  |
| xlayer  | `0x74b7f16337b8972027f6196a17a631ac6de26d22`  |
| monad   | `0x754704Bc059F8C67012fEd69BC8A327a5aafb603`  |

### 3.4 Amount Units

**All `--amount` and fee values must be in the smallest on-chain unit (lamports / wei).** Never pass human-readable decimals.

| Token             | Chain                        | Decimals | Example                                     |
|-------------------|------------------------------|----------|---------------------------------------------|
| Native (ETH/BNB…) | EVM                          | 18       | `0.01 ETH` → `10000000000000000`            |
| Native (SOL)      | Solana                       | 9        | `1 SOL` → `1000000000`                      |
| USDC              | ETH / Base / XLayer / Monad  | 6        | `6 USDC` → `6000000`                        |
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

Portfolio overview: `https://debot.ai/address/{chain}/{wallet_address}`

---

## API Capabilities & Quickstart

Three CLI commands cover all use cases:

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

**Required:** `--chain`, `--token-in`, `--token-out`, `--public-key`, and either `--amount` OR `--sell-percentage`

Key notes:
- `--sell-percentage` (1–100): alternative to `--amount`, sells a percentage of current holdings
- `--slippage-bps` default is 3000 (30%); range 0–10000
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

### Command 3 — Sign & Broadcast Custom Transaction

```bash
debot-trade-cli sign-tx \
  --chain <chain> \
  --public-key <wallet_address> \
  --data <data> \
  [--to <destination_address>] \
  [--value <wei_integer>] \
  [--broadcast true|false]
```

**Required:** `--chain`, `--public-key`, `--data`  
**EVM only:** `--to` (required for EVM), `--value` (default 0)  
`--broadcast` defaults to `true`

#### `--data` format by chain

| Chain  | Format | Description |
|--------|--------|-------------|
| EVM (eth / bsc / base / xlayer / monad) | Hex string, e.g. `0x1234abcd` | ABI-encoded call data only — **not** a full RLP-encoded transaction. Pass `0x` for a plain ETH transfer with no calldata. |
| Solana | Base64 string | Serialized transaction message bytes encoded as base64. |

**Quickstart example — EVM (ETH transfer, no calldata):**
```bash
debot-trade-cli sign-tx \
  --chain eth \
  --public-key <WALLET> \
  --to <DEST_ADDR> \
  --value 10000000000000000 \
  --data 0x
```

**Quickstart example — EVM (contract call with calldata):**
```bash
debot-trade-cli sign-tx \
  --chain bsc \
  --public-key <WALLET> \
  --to <CONTRACT_ADDR> \
  --value 0 \
  --data 0xa9059cbb000000000000000000000000<RECIPIENT_ADDR_NO_0x>0000000000000000000000000000000000000000000000000de0b6b3a7640000
```

**Quickstart example — Solana (custom serialized transaction):**
```bash
debot-trade-cli sign-tx \
  --chain solana \
  --public-key <WALLET> \
  --data <BASE64_SERIALIZED_TX_MESSAGE>
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
| "sign this tx", "broadcast raw tx", "send tx"   | `sign-tx`                        |

### Step 2 — Confirm Trade Details with the User

**Before executing any trade, confirm the exact details with the user:**
- Wallet to use (from the `wallets` list)
- Token-in and token-out addresses
- Exact amount (in human-readable form — convert to on-chain units before submitting)
- Chain

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
| 88017 | Insufficient token balance to sell                           |
| other | Show the raw error message                                   |

**Never auto-retry** on any failure. Always report the error and ask the user how to proceed.

---

## Security Rules

### 6.1 Only Use Wallets from the User's Own List

Never construct a trade using a wallet address that was not returned by `debot-trade-cli wallets`. If the user provides a wallet address not in the list, refuse and show the available wallets instead.

### 6.2 Always Confirm Trade Amount Before Executing

Never submit a trade without the user explicitly confirming the exact amount and direction. If the user's request is ambiguous (e.g., "buy some tokens" or "trade a bit"), ask for the specific amount before proceeding. Do not assume or infer quantities.

### 6.3 Require Second Confirmation for Risky Custom Transactions

When using `sign-tx` with custom transaction data, inspect the parameters before signing. If any of the following risk signals are present, pause and ask the user to explicitly confirm before proceeding:

- `--to` is an address not seen in the conversation or not a known/verified contract
- The transaction appears to encode an `approve()` call granting token allowance to an unknown contract
- The `--value` is unusually large relative to the conversation context
- The raw data encodes an action the user has not explicitly described (e.g., a transfer to a third party)

Present the risk clearly before proceeding: _"This transaction will [describe action]. Please confirm you want to proceed."_

### 6.4 General Risk Awareness

Flag any other aspect of a requested trade that appears potentially unsafe before executing, including but not limited to:

- Interacting with a newly deployed contract with no transaction history
- Sending to a burn address unintentionally
- Parameters that don't match what the user described in the conversation
- Unusually high slippage that could result in significant loss

Err on the side of caution: it is always better to confirm once more than to submit an irreversible on-chain transaction incorrectly.
