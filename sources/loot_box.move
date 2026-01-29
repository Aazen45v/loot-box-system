/// Module: loot_box_system::loot_box
/// 
/// A loot box system where players can purchase loot boxes using fungible tokens
/// and receive randomly generated in-game items (NFTs) with varying rarity levels.
/// 
/// The randomness is verifiable and tamper-proof using Sui's native on-chain randomness.
module loot_box::loot_box {
    // ===== Imports =====
    use sui::coin::{Self, Coin};
    use sui::event;
    use sui::random::{Self, Random};

    // ===== Error Codes =====
    /// Error when payment amount is insufficient
    const EInsufficientPayment: u64 = 0;
    /// Error when caller is not the admin
    const ENotAdmin: u64 = 1;
    /// Error when rarity weights don't sum to 100
    const EInvalidWeights: u64 = 2;

    // ===== Constants =====
    /// Default price for a loot box (in token base units)
    const DEFAULT_LOOT_BOX_PRICE: u64 = 100;

    // Rarity tier constants
    const RARITY_COMMON: u8 = 0;
    const RARITY_RARE: u8 = 1;
    const RARITY_EPIC: u8 = 2;
    const RARITY_LEGENDARY: u8 = 3;

    // Default rarity weights (must sum to 100)
    const DEFAULT_COMMON_WEIGHT: u8 = 60;
    const DEFAULT_RARE_WEIGHT: u8 = 25;
    const DEFAULT_EPIC_WEIGHT: u8 = 12;
    const DEFAULT_LEGENDARY_WEIGHT: u8 = 3;

    // ===== Structs =====

    /// Shared object storing game configuration
    /// Contains rarity weights, loot box price, and treasury
    public struct GameConfig<phantom T> has key {
        id: UID,
        /// Weight for Common rarity (0-100)
        common_weight: u8,
        /// Weight for Rare rarity (0-100)
        rare_weight: u8,
        /// Weight for Epic rarity (0-100)
        epic_weight: u8,
        /// Weight for Legendary rarity (0-100)
        legendary_weight: u8,
        /// Price to purchase one loot box
        loot_box_price: u64,
        /// Treasury collecting payments
        treasury: Coin<T>,
    }

    /// Capability granting admin privileges
    /// Holder can update game configuration
    public struct AdminCap has key, store {
        id: UID,
    }

    /// Owned object representing an unopened loot box
    /// Must be opened to receive a GameItem
    public struct LootBox has key, store {
        id: UID,
    }

    /// NFT representing an in-game item
    /// Has rarity tier and power level determined by randomness
    public struct GameItem has key, store {
        id: UID,
        /// Name of the item
        name: std::string::String,
        /// Rarity tier (0=Common, 1=Rare, 2=Epic, 3=Legendary)
        rarity: u8,
        /// Power level within the rarity's range
        power: u8,
    }

    // ===== Events =====

    /// Emitted when a loot box is opened
    public struct LootBoxOpened has copy, drop {
        /// ID of the minted GameItem
        item_id: ID,
        /// Rarity tier of the item
        rarity: u8,
        /// Power level of the item
        power: u8,
        /// Address of the player who opened the box
        owner: address,
    }

    // ===== Public Functions =====

    /// Initialize the game with default configuration
    /// Creates a shared GameConfig and transfers AdminCap to the caller
    /// 
    /// # Type Parameters
    /// * `T` - The fungible token type used for payments
    /// 
    /// # Arguments
    /// * `ctx` - Transaction context
    public fun init_game<T>(ctx: &mut TxContext) {
        // TODO: Implement game initialization
        // 1. Create GameConfig with default weights and price
        // 2. Create empty treasury Coin<T>
        // 3. Share the GameConfig object
        // 4. Create AdminCap and transfer to tx sender
        abort 0
    }

    /// Purchase a loot box by paying the required token amount
    /// 
    /// # Type Parameters
    /// * `T` - The fungible token type used for payments
    /// 
    /// # Arguments
    /// * `config` - Shared GameConfig object
    /// * `payment` - Coin used for payment (must be >= loot_box_price)
    /// * `ctx` - Transaction context
    /// 
    /// # Returns
    /// * `LootBox` - An unopened loot box object
    public fun purchase_loot_box<T>(
        config: &mut GameConfig<T>,
        payment: Coin<T>,
        ctx: &mut TxContext
    ): LootBox {
        // TODO: Implement loot box purchase
        // 1. Verify payment amount >= loot_box_price
        // 2. Add payment to treasury
        // 3. Create and return new LootBox object
        abort 0
    }

    /// Open a loot box and receive a random GameItem
    /// 
    /// IMPORTANT: This function MUST be marked as `entry` (not `public`) 
    /// to securely use on-chain randomness. This prevents the random value
    /// from being inspected by other functions before commitment.
    /// 
    /// # Type Parameters
    /// * `T` - The fungible token type used for payments
    /// 
    /// # Arguments
    /// * `config` - Shared GameConfig to read rarity weights
    /// * `loot_box` - The loot box to open (will be destroyed)
    /// * `r` - The Random object from address 0x8
    /// * `ctx` - Transaction context
    entry fun open_loot_box<T>(
        config: &GameConfig<T>,
        loot_box: LootBox,
        r: &Random,
        ctx: &mut TxContext
    ) {
        // TODO: Implement loot box opening with secure randomness
        // 
        // CRITICAL RANDOMNESS STEPS:
        // 1. Create a new RandomGenerator: let mut gen = random::new_generator(r, ctx);
        // 2. Generate random number 0-99: let roll = random::generate_u8_in_range(&mut gen, 0, 99);
        // 3. Determine rarity based on roll and weights
        // 4. Generate power level within rarity's range
        // 5. Create GameItem with determined stats
        // 6. Emit LootBoxOpened event
        // 7. Delete the loot box
        // 8. Transfer GameItem to sender
        //
        // WARNING: Never pass RandomGenerator as a function argument!
        abort 0
    }

    /// Get the stats of a GameItem
    /// 
    /// # Arguments
    /// * `item` - Reference to the GameItem
    /// 
    /// # Returns
    /// * `(String, u8, u8)` - Tuple of (name, rarity, power)
    public fun get_item_stats(item: &GameItem): (std::string::String, u8, u8) {
        // TODO: Return item's name, rarity tier, and power level
        abort 0
    }

    /// Transfer a GameItem to another address
    /// 
    /// # Arguments
    /// * `item` - The GameItem to transfer
    /// * `recipient` - Address to receive the item
    public fun transfer_item(item: GameItem, recipient: address) {
        // TODO: Transfer the item to the recipient
        abort 0
    }

    /// Burn (destroy) an unwanted GameItem
    /// 
    /// # Arguments
    /// * `item` - The GameItem to destroy
    public fun burn_item(item: GameItem) {
        // TODO: Delete/destroy the GameItem
        abort 0
    }

    /// Update the rarity weights (admin only)
    /// 
    /// # Type Parameters
    /// * `T` - The fungible token type
    /// 
    /// # Arguments
    /// * `_admin` - AdminCap proving admin privileges
    /// * `config` - Mutable reference to GameConfig
    /// * `common` - New weight for Common rarity
    /// * `rare` - New weight for Rare rarity
    /// * `epic` - New weight for Epic rarity
    /// * `legendary` - New weight for Legendary rarity
    public fun update_rarity_weights<T>(
        _admin: &AdminCap,
        config: &mut GameConfig<T>,
        common: u8,
        rare: u8,
        epic: u8,
        legendary: u8
    ) {
        // TODO: Implement weight update
        // 1. Verify weights sum to 100
        // 2. Update config with new weights
        abort 0
    }

    // ===== Helper Functions =====

    /// Determine rarity tier based on random roll and weights
    /// 
    /// # Arguments
    /// * `roll` - Random number 0-99
    /// * `common_weight` - Weight for Common
    /// * `rare_weight` - Weight for Rare
    /// * `epic_weight` - Weight for Epic
    /// 
    /// # Returns
    /// * `u8` - Rarity tier constant
    fun determine_rarity(roll: u8, common_weight: u8, rare_weight: u8, epic_weight: u8): u8 {
        // TODO: Implement rarity determination
        // If roll < common_weight -> RARITY_COMMON
        // Else if roll < common_weight + rare_weight -> RARITY_RARE
        // Else if roll < common_weight + rare_weight + epic_weight -> RARITY_EPIC
        // Else -> RARITY_LEGENDARY
        abort 0
    }

    /// Generate item name based on rarity
    /// 
    /// # Arguments
    /// * `rarity` - The rarity tier
    /// 
    /// # Returns
    /// * `String` - Generated item name
    fun generate_item_name(rarity: u8): std::string::String {
        // TODO: Return appropriate name based on rarity
        // Common -> "Common Sword"
        // Rare -> "Rare Blade"
        // Epic -> "Epic Weapon"
        // Legendary -> "Legendary Artifact"
        abort 0
    }

    /// Calculate power range based on rarity
    /// 
    /// # Arguments
    /// * `rarity` - The rarity tier
    /// 
    /// # Returns
    /// * `(u8, u8)` - Tuple of (min_power, max_power)
    fun get_power_range(rarity: u8): (u8, u8) {
        // TODO: Return power range for the given rarity
        // Common: 1-10
        // Rare: 11-25
        // Epic: 26-40
        // Legendary: 41-50
        abort 0
    }

    // ===== Getter Functions =====

    /// Get the current loot box price
    public fun get_loot_box_price<T>(config: &GameConfig<T>): u64 {
        config.loot_box_price
    }

    /// Get all rarity weights
    public fun get_rarity_weights<T>(config: &GameConfig<T>): (u8, u8, u8, u8) {
        (config.common_weight, config.rare_weight, config.epic_weight, config.legendary_weight)
    }
}