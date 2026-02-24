# 🎮 Loot Box System with On-Chain Randomness

## 🏆 Alkimi Hackathon - Problem Statement #2: Gaming

This repository implements a **Decentralized Loot Box System** built using Sui Move smart contracts. It serves as the backend logic for a Web3 game where players can purchase loot boxes and receive randomly generated in-game NFTs with varying rarity levels.

### 🌟 Features Implemented
1. **Purchase System**: Players pay `1000 SUI` to receive an unopened `LootBox`.
2. **True Randomness**: Uses Sui's native on-chain `sui::random` to securely determine the rewards, making drops mathematically fair and tamper-proof.
3. **NFT Minting & Rarity Tiers**: Random item generation drops items from four tiers: Common (60%), Rare (25%), Epic (12%), and Legendary (3%).
4. **Pity System (Bonus)**: If a player opens 30 loot boxes consecutively without getting a Legendary item, their 31st box guarantees a Legendary drop!
5. **Item Lifecycle**: Complete support for fetching stats, transferring, and burning items.

### 🚀 How to Run the Project
This is a smart contract backend, so it is compiled, tested, and deployed using the Sui CLI rather than run as a traditional app. 

1. **Install the Sui CLI**: Make sure you have the [Sui CLI installed](https://docs.sui.io/guides/developer/getting-started/sui-install) locally.
2. **Compile the Code**: Run `sui move build` from the project root to compile the contracts.
3. **Run the Test Suite**: Run `sui move test` to execute the built-in unit tests verifying initialization, purchasing, opening (with mocked randomness), and the pity system.
4. **Deploy to Testnet**: Run `sui client publish --gas-budget 100000000` to deploy the package to the Sui Testnet.

---

| Attribute | Value |
|-----------|-------|
| **Domain** | Gaming / NFTs |
| **Difficulty** | Medium |
| **Time** | 48 Hours |
| **Language** | Sui Move |

---

## 📋 Table of Contents

1. [Problem Overview](#-problem-overview)
2. [Getting Started](#-getting-started)
3. [Project Structure](#-project-structure)
4. [Core Mechanics](#-core-mechanics)
5. [Functional Requirements](#-functional-requirements)
6. [Sui-Specific Requirements](#-sui-specific-requirements)
7. [Implementation Guide](#-implementation-guide)
8. [Testing](#-testing)
9. [Evaluation Criteria](#-evaluation-criteria)
10. [Bonus Challenge](#-bonus-challenge)
11. [Resources](#-resources)

---

## 🎯 Problem Overview

### Background

Loot boxes are a popular game mechanic where players purchase mystery containers that yield random rewards. In Web3 gaming, these rewards are typically NFTs with different rarity tiers. The key challenge is ensuring that the randomness determining rewards is truly fair, unpredictable, and verifiable by anyone.

Sui provides a native on-chain randomness module (`sui::random`) that generates cryptographically secure random values through a distributed randomness beacon operated by validators.

### What You'll Build

- A purchase system for loot boxes using fungible tokens
- Secure random item generation using Sui's on-chain randomness
- NFT minting with rarity tiers and power levels
- Item lifecycle management (transfer, burn)
- Admin controls for game configuration

### Rarity Distribution

| Tier | Weight | Drop Rate | Power Range |
|------|--------|-----------|-------------|
| Common | 60 | 60% | 1 - 10 |
| Rare | 25 | 25% | 11 - 25 |
| Epic | 12 | 12% | 26 - 40 |
| Legendary | 3 | 3% | 41 - 50 |

> **Note:** Weights sum to 100. A random number 0-99 determines the tier.

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- **Rust** (latest stable version)
- **Sui CLI** (latest version)
- **Git**

### Step 1: Install Sui CLI

```bash
# Install using cargo
cargo install --locked --git https://github.com/MystenLabs/sui.git --branch testnet sui

# Verify installation
sui --version
```

For other installation methods, see the [official Sui installation guide](https://docs.sui.io/guides/developer/getting-started/sui-install).

### Step 2: Configure Sui Client

```bash
# Initialize Sui client (first time only)
sui client

# This will prompt you to:
# 1. Connect to a network (choose Testnet for development)
# 2. Generate a new keypair or import existing one
```

### Step 3: Create/Import Wallet

```bash
# Generate a new wallet address
sui client new-address ed25519

# View your active address
sui client active-address

# List all addresses
sui client addresses
```

### Step 4: Get Testnet SUI Tokens

You'll need testnet SUI tokens to deploy and test your contract.

**Option 1: Sui Faucet Discord**
1. Join the [Sui Discord](https://discord.gg/sui)
2. Go to `#testnet-faucet` channel
3. Type `!faucet <YOUR_ADDRESS>`

**Option 2: Web Faucet**
- Visit https://faucet.testnet.sui.io/
- Enter your address and request tokens

**Option 3: CLI Faucet**
```bash
sui client faucet
```

### Step 5: Clone/Setup Project

```bash
# Navigate to your project directory
cd loot_box_challenge

# Verify project structure
ls -la
# Should show: Move.toml, sources/, tests/
```

### Step 6: Build the Project

```bash
# Build the Move package
sui move build

# You'll see compilation errors initially - that's expected!
# The boilerplate has TODOs you need to implement.
```

### Step 7: Run Tests

```bash
# Run all tests
sui move test

# Run specific test
sui move test test_init_game

# Run tests with verbose output
sui move test --verbose
```

### Step 8: Deploy to Testnet

Once your implementation is complete:

```bash
# Deploy to testnet
sui client publish --gas-budget 100000000

# Save the Package ID from the output - you'll need it!
```

---

## 📁 Project Structure

```
loot_box_challenge/
├── Move.toml                 # Package configuration
├── sources/
│   └── loot_box.move         # Main module (implement here)
└── tests/
    └── loot_box_tests.move   # Test suite
```

### Key Files

- **`Move.toml`**: Package manifest with dependencies configured for Sui testnet
- **`sources/loot_box.move`**: Contains all struct definitions, function signatures, and TODOs
- **`tests/loot_box_tests.move`**: Test scaffolding with test signatures

---

## ⚙️ Core Mechanics

### 1. Purchase Flow
Players pay tokens → Receive an unopened `LootBox` object

### 2. Secure Opening
`LootBox` + On-chain randomness → Determine item rarity

### 3. NFT Minting
Random outcome → Create unique `GameItem` NFT with stats

### 4. Item Lifecycle
- **Transfer**: Send items to other players
- **Burn**: Destroy unwanted items

---

## 📝 Functional Requirements

| # | Function | Description |
|---|----------|-------------|
| 1 | `init_game<T>()` | One-time initializer creating shared `GameConfig` with rarity weights, price, and `AdminCap` |
| 2 | `purchase_loot_box<T>()` | User pays tokens and receives an owned `LootBox` object (unopened) |
| 3 | `open_loot_box<T>()` | Opens loot box using `sui::random`. Mints `GameItem` NFT. Burns `LootBox`. **MUST be entry function** |
| 4 | `get_item_stats()` | View function returning item's name, rarity tier, and power level |
| 5 | `transfer_item()` | Allows owner to transfer a `GameItem` to another address |
| 6 | `burn_item()` | Owner can destroy an unwanted item |
| 7 | `update_rarity_weights<T>()` | Admin can adjust drop rates. Requires `AdminCap` |

---

## 🔐 Sui-Specific Requirements

### On-Chain Randomness (CRITICAL)

This is the most important part of the challenge. Sui provides secure on-chain randomness through the `sui::random` module.

#### Key Rules:

1. **Use `sui::random::Random`** from address `0x8`
2. **The `open_loot_box` function MUST be `entry`** (not `public`)
3. **Create RandomGenerator inside the consuming function**
4. **NEVER pass RandomGenerator as a function argument**

#### Correct Usage Pattern:

```move
// ✅ CORRECT: entry function, generator created inside
entry fun open_loot_box<T>(
    config: &GameConfig<T>,
    loot_box: LootBox,
    r: &Random,
    ctx: &mut TxContext
) {
    // Create generator INSIDE the function
    let mut gen = random::new_generator(r, ctx);
    
    // Generate random number 0-99
    let roll = random::generate_u8_in_range(&mut gen, 0, 99);
    
    // Use roll to determine rarity...
}
```

```move
// ❌ WRONG: public function (not entry)
public fun open_loot_box<T>(...) { }

// ❌ WRONG: passing generator as argument
entry fun open_loot_box<T>(gen: &mut RandomGenerator, ...) { }
```

#### Why Entry Functions?

The `entry` modifier ensures the function can only be called directly in a transaction, not by other Move functions. This prevents:
- Other contracts from calling your function and inspecting the random value before deciding whether to proceed
- "Reroll" attacks where bad outcomes are discarded

### Object Model

| Object | Type | Description |
|--------|------|-------------|
| `GameConfig<T>` | Shared | Stores game settings (weights, price, treasury) |
| `LootBox` | Owned | Represents an unopened loot box |
| `GameItem` | Owned (NFT) | In-game item with `key` and `store` abilities |
| `AdminCap` | Owned | Capability for admin functions |

### Events

Use `sui::event` to emit events when a loot box is opened:

```move
use sui::event;

public struct LootBoxOpened has copy, drop {
    item_id: ID,
    rarity: u8,
    power: u8,
    owner: address,
}

// In your function:
event::emit(LootBoxOpened {
    item_id: object::id(&item),
    rarity,
    power,
    owner: tx_context::sender(ctx),
});
```

---

## 🛠️ Implementation Guide

### Step 1: Understand the Structs

Review the struct definitions in `loot_box.move`:

- `GameConfig<T>`: Holds all game settings and the payment treasury
- `AdminCap`: Proves admin privileges
- `LootBox`: Simple wrapper that gets destroyed when opened
- `GameItem`: The NFT with name, rarity, and power

### Step 2: Implement init_game

```move
public fun init_game<T>(ctx: &mut TxContext) {
    // 1. Create GameConfig with defaults
    // 2. Use coin::zero<T>() for empty treasury
    // 3. transfer::share_object() for GameConfig
    // 4. transfer::transfer() AdminCap to sender
}
```

### Step 3: Implement purchase_loot_box

```move
public fun purchase_loot_box<T>(
    config: &mut GameConfig<T>,
    payment: Coin<T>,
    ctx: &mut TxContext
): LootBox {
    // 1. assert!(coin::value(&payment) >= config.loot_box_price, EInsufficientPayment)
    // 2. coin::join(&mut config.treasury, payment)
    // 3. Return new LootBox
}
```

### Step 4: Implement open_loot_box (Most Important!)

```move
entry fun open_loot_box<T>(
    config: &GameConfig<T>,
    loot_box: LootBox,
    r: &Random,
    ctx: &mut TxContext
) {
    // 1. Create random generator
    let mut gen = random::new_generator(r, ctx);
    
    // 2. Generate rarity roll (0-99)
    let roll = random::generate_u8_in_range(&mut gen, 0, 99);
    
    // 3. Determine rarity from roll
    let rarity = determine_rarity(roll, ...);
    
    // 4. Get power range for rarity
    let (min_power, max_power) = get_power_range(rarity);
    
    // 5. Generate power within range
    let power = random::generate_u8_in_range(&mut gen, min_power, max_power);
    
    // 6. Create GameItem
    // 7. Emit event
    // 8. Delete loot box: let LootBox { id } = loot_box; object::delete(id);
    // 9. Transfer item to sender
}
```

### Step 5: Implement Helper Functions

Complete the helper functions:
- `determine_rarity()`: Map roll to rarity tier
- `generate_item_name()`: Create name based on rarity
- `get_power_range()`: Return min/max power for rarity

### Step 6: Implement Remaining Functions

- `get_item_stats()`: Return item properties
- `transfer_item()`: Use `transfer::public_transfer()`
- `burn_item()`: Destructure and delete
- `update_rarity_weights()`: Validate sum = 100, update config

---

## 🧪 Testing

### Running Tests

```bash
# Run all tests
sui move test

# Run with gas profiling
sui move test --gas-profiling

# Run specific test file
sui move test --filter loot_box_tests
```

### Test Checklist

| Test | Description |
|------|-------------|
| `test_init_game` | Verify GameConfig created with correct defaults |
| `test_purchase_loot_box` | User can purchase with correct payment |
| `test_purchase_insufficient_payment` | Fails with insufficient payment |
| `test_open_loot_box` | Correct item minted based on random value |
| `test_transfer_item` | Item can be transferred between addresses |
| `test_burn_item` | Item can be destroyed by owner |
| `test_update_rarity_weights` | Admin can update weights |
| `test_update_weights_invalid_sum` | Fails if weights ≠ 100 |

### Testing Randomness

Testing on-chain randomness requires special setup. See the [Sui testing documentation](https://docs.sui.io/guides/developer/advanced/randomness-onchain#testing) for details on mocking the Random object.

---

## 📊 Evaluation Criteria

| Criterion | Weight | Description |
|-----------|--------|-------------|
| **Secure Randomness** | 35% | Correct use of `sui::random` with entry function protection |
| **Correctness** | 30% | Object lifecycle works end-to-end |
| **Events** | 15% | Proper event emission with useful data |
| **Code Quality** | 20% | Readable code, tests, and comments |

---

## 🌟 Bonus Challenge (Optional)

Implement a **pity system**: If a user opens 30 loot boxes without receiving a Legendary item, guarantee their next one is Legendary.

**Hints:**
- Track per-user counters using **dynamic fields** on GameConfig
- Reset counter when user receives Legendary
- Check counter before random roll

```move
// Example structure for tracking
use sui::dynamic_field;

// In open_loot_box:
// 1. Get user's current counter (or 0 if not exists)
// 2. If counter >= 30, force Legendary
// 3. Else, use random roll
// 4. Update counter (reset on Legendary, increment otherwise)
```

---

## 📚 Resources

### Sui Documentation

- [On-Chain Randomness Guide](https://docs.sui.io/guides/developer/advanced/randomness-onchain)
- [Gaming on Sui](https://docs.sui.io/concepts/gaming)
- [NFT Creation Guide](https://docs.sui.io/guides/developer/nft)
- [Move Language Reference](https://docs.sui.io/concepts/sui-move-concepts)

### Sui Move Examples

- [Sui Framework Source](https://github.com/MystenLabs/sui/tree/main/crates/sui-framework)
- [Move Examples](https://examples.sui.io/)

### Testing

- [Sui Move Testing](https://docs.sui.io/concepts/sui-move-concepts/packages/custom-policies/tests)
- [Test Scenario Framework](https://docs.sui.io/concepts/sui-move-concepts/packages/custom-policies/tests#test-scenario)

---

## 💡 Tips for Success

1. **Start with init_game** - Get the basic setup working first
2. **Test incrementally** - Write tests as you implement each function
3. **Read the randomness docs carefully** - The entry function requirement is critical
4. **Use the Sui Discord** - Great community support for questions
5. **Check gas costs** - Optimize if your operations are expensive

---

**Good luck! Build something amazing. 🚀**

---

## 📄 Hackathon Submission Report: Decentralized Loot Box System

### 1. Project Identification & Context

This technical report evaluates the submission for the Alkimi Hackathon Phase II, demonstrating a robust implementation of secure on-chain randomness within the Sui ecosystem. The repository consists of a complete Sui Move package, featuring three distinct commits and a comprehensive `walkthrough.md` providing architectural context.

| Hackathon Phase | Problem Statement | Project Name | Development Language | Repository Link |
| --- | --- | --- | --- | --- |
| Alkimi Hackathon Phase II | Problem Statement #2: Gaming | Loot Box System | Sui Move | [Aazen45v/loot-box-system](https://github.com/Aazen45v/loot-box-system) |

### 2. Core System Mechanics

The Loot Box system is designed around a secure, non-custodial user journey that ensures the integrity of digital asset generation.

1. **Purchase Flow**: A user invokes the purchase function, providing 1000 SUI. The contract validates the payment and issues an owned `LootBox` object to the caller.
2. **Secure Opening**: The user consumes the `LootBox` object as an argument in a non-composable private entry function. This design safely invokes the Sui randomness beacon to determine the outcome.
3. **NFT Minting**: Based on the entropy provided by the randomness generator, the system mints a `GameItem` NFT with unique metadata, including rarity and power stats.
4. **Item Lifecycle**: Once the `GameItem` is minted, the owner retains full autonomy to either use the `transfer::public_transfer` function for peer-to-peer exchange or execute the `burn` function to permanently remove the object from the state.

### 3. Object Model & Smart Contract Architecture

The implementation utilizes Sui’s object-oriented paradigm to manage state and permissions, specifically distinguishing between shared and owned objects to optimize for transaction sequencing.

* **GameConfig**: A Shared Object possessing the key ability. It acts as the central state for rarity weights, pricing, and the treasury. As a shared object, transactions interacting with `GameConfig` undergo full consensus sequencing.
* **LootBox**: An Owned Object with the key ability. It represents an unopened container that must be destroyed (burned) during the NFT generation process.
* **GameItem**: An Owned NFT possessing both key and store abilities. This enables the item to be stored within other objects (like a player’s inventory) or traded on external marketplaces.
* **AdminCap**: An Owned Object with the key ability, specifically transferred to the deployer’s address during the init function. It provides the necessary capability to perform restricted governance operations.

### 4. Secure On-Chain Randomness Implementation

The system integrates the `sui::random` module to provide tamper-proof rewards. The implementation adheres to strict security protocols to prevent manipulation and "reroll" attacks through the following requirements:

* [x] Use of `sui::random::Random` retrieved from the protocol address `0x8`.
* [x] Implementation of `open_loot_box` as a private entry function, ensuring it cannot be composed within a programmable transaction block (PTB) or called by malicious intermediate contracts.
* [x] Internal instantiation of the `RandomGenerator` using `random::new_generator(r, ctx)`, where `r` is the `Random` object and `ctx` is the `TxContext`. The generator is never passed as a function argument.
* [x] Utilization of `generate_u8_in_range(0, 99)` to ensure a uniform distribution for rarity mapping.

**Security Synthesis: Composition Attacks**
By enforcing the `entry` modifier and local generator instantiation, the system mitigates "Composition Attacks." This prevents a malicious actor from creating a wrapper contract that could inspect the random outcome and abort the transaction if the result is unfavorable, thereby maintaining the mathematical integrity of the drop rates.

### 5. NFT Rarity Tiers and Power Distribution

The reward system employs a weighted probability framework. A random value $n \in [0, 99]$ is mapped to discrete intervals to determine the rarity tier and subsequent power range.

| Tier | Weight/Drop Rate | Discrete Interval | Power Range |
| --- | --- | --- | --- |
| Common | 60% | [0 - 59] | 1 - 10 |
| Rare | 25% | [60 - 84] | 11 - 25 |
| Epic | 12% | [85 - 96] | 26 - 40 |
| Legendary | 3% | [97 - 99] | 41 - 50 |

### 6. Bonus Challenge: Implementation of the Pity System

The submission successfully implements the optional "Pity System" to mitigate the "bad luck" variance in the gaming economy.

* **Mechanism**: If a user fails to receive a Legendary item within 30 consecutive openings, the 31st attempt provides a 100% guaranteed Legendary drop.
* **Technical Implementation**: The system utilizes dynamic fields attached to the `GameConfig` shared object. The user’s address serves as the Key, while a `u64` counter serves as the Value.
* **Counter Logic**: The counter increments with every non-Legendary drop and is reset to zero immediately upon the acquisition of a Legendary item, whether through a standard roll or the pity guarantee.

### 7. Administrative Controls and Governance

Governance is mediated through the `AdminCap` capability. The primary administrative function, `update_rarity_weights`, allows the holder to adjust the game's economic balance. To ensure system stability, the function includes a strict validation check: the four rarity weights must sum exactly to 100. If this condition is not met, the transaction is designed to abort, preventing the configuration of an invalid state.

### 8. Quality Assurance and Deployment Status

The project has been verified through a rigorous Move test suite and successful network deployment.

* **Verified Test Cases**: Unit tests cover contract initialization, handling of insufficient SUI payments, and item destruction. Randomness testing was conducted using mocked randomness, specifically utilizing `random::create_for_testing` to simulate the Random object (`0x8`) which is otherwise restricted to the protocol layer.
* **Deployment Status**: The package is successfully deployed to the Sui Testnet. The deployment was executed via the Sui CLI with a gas budget of 100,000,000 MIST (0.1 SUI), confirming the contract's readiness for high-concurrency environments.
