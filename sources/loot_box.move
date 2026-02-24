module loot_box::loot_box {
    use sui::coin::{Self, Coin};
    use sui::balance::{Self, Balance};
    use sui::sui::SUI;
    use sui::event;
    use sui::random::{Self, Random};
    use sui::dynamic_field;
    use std::string::{Self, String};

    // --- Errors ---
    const EInsufficientPayment: u64 = 0;
    const EInvalidWeights: u64 = 1;

    // --- Structs ---

    /// Shared Game Configuration object.
    public struct GameConfig<phantom T> has key {
        id: UID,
        /// Weights for rarity tiers (Common, Rare, Epic, Legendary).
        /// Total should sum precisely to 100.
        common_weight: u8,
        rare_weight: u8,
        epic_weight: u8,
        legendary_weight: u8,
        /// The cost of one Loot Box.
        loot_box_price: u64,
        /// Game Treasury to accumulate purchased funds.
        treasury: Balance<T>,
    }

    /// An unopened LootBox owned by a player.
    public struct LootBox has key, store {
        id: UID
    }

    /// Admin capability required to manage configuration.
    public struct AdminCap has key, store {
        id: UID
    }

    /// The opened NFT item owned by the player.
    public struct GameItem has key, store {
        id: UID,
        name: String,
        rarity: u8,
        power: u8,
    }

    // --- Events ---

    public struct LootBoxOpened has copy, drop {
        item_id: ID,
        rarity: u8,
        power: u8,
        owner: address,
    }

    // --- Functions ---

    /// Initialize the game, set default configuration, and issue the `AdminCap`.
    public fun init_game<T>(ctx: &mut TxContext) {
        let admin_cap = AdminCap {
            id: object::new(ctx)
        };
        transfer::transfer(admin_cap, ctx.sender());

        let config = GameConfig<T> {
            id: object::new(ctx),
            common_weight: 60,
            rare_weight: 25,
            epic_weight: 12,
            legendary_weight: 3,
            loot_box_price: 1000, // example price; can be adjusted
            treasury: balance::zero<T>()
        };
        transfer::share_object(config);
    }

    /// Purchase a LootBox by paying the required `Coin<T>`.
    public fun purchase_loot_box<T>(
        config: &mut GameConfig<T>,
        mut payment: Coin<T>,
        ctx: &mut TxContext
    ): LootBox {
        assert!(payment.value() >= config.loot_box_price, EInsufficientPayment);
        
        let exact_payment = payment.split(config.loot_box_price, ctx);
        balance::join(&mut config.treasury, exact_payment.into_balance());
        
        // return change if any
        if (payment.value() > 0) {
            transfer::public_transfer(payment, ctx.sender());
        } else {
            payment.destroy_zero();
        };

        LootBox {
            id: object::new(ctx)
        }
    }

    /// Open an owned `LootBox`. This is an `entry` function securely wrapped with randomness.
    entry fun open_loot_box<T>(
        config: &mut GameConfig<T>,
        loot_box: LootBox,
        r: &Random,
        ctx: &mut TxContext
    ) {
        let sender = ctx.sender();
        // Create generator INSIDE the function as required by standard practices.
        let mut gen = random::new_generator(r, ctx);

        // 1. Get user's current counter (or 0 if not exists)
        let mut user_counter = if (dynamic_field::exists_(&config.id, sender)) {
            *dynamic_field::borrow<address, u8>(&config.id, sender)
        } else {
            0
        };

        let rarity;

        // 2. If counter >= 30, force Legendary
        if (user_counter >= 30) {
            rarity = 3;
            // 4. Update counter (reset on Legendary)
            user_counter = 0;
        } else {
            // Generate rarity roll 0-99
            let roll = random::generate_u8_in_range(&mut gen, 0, 99);

            // Map roll to Rarity
            rarity = determine_rarity(roll, config);

            // 4. Update counter (increment otherwise)
            if (rarity == 3) {
                user_counter = 0;
            } else {
                user_counter = user_counter + 1;
            };
        };

        if (dynamic_field::exists_(&config.id, sender)) {
            let field_mut = dynamic_field::borrow_mut<address, u8>(&mut config.id, sender);
            *field_mut = user_counter;
        } else {
            dynamic_field::add(&mut config.id, sender, user_counter);
        };
        
        // Pick Power Range
        let (min_power, max_power) = get_power_range(rarity);
        let power = random::generate_u8_in_range(&mut gen, min_power, max_power);

        // Determine name
        let name = generate_item_name(rarity);

        // Mint Item
        let item = GameItem {
            id: object::new(ctx),
            name,
            rarity,
            power,
        };

        // Emit Event
        event::emit(LootBoxOpened {
            item_id: object::id(&item),
            rarity,
            power,
            owner: sender,
        });

        // Destroy Loot Box Wrapper
        let LootBox { id } = loot_box;
        object::delete(id);

        transfer::public_transfer(item, sender);
    }

    // --- Helper Logic ---

    // Return the designated tier for a particular roll given the probability configuration.
    // Tiers: 0=Common, 1=Rare, 2=Epic, 3=Legendary.
    fun determine_rarity<T>(roll: u8, config: &GameConfig<T>): u8 {
        if (roll < config.common_weight) {
            0
        } else if (roll < config.common_weight + config.rare_weight) {
            1
        } else if (roll < config.common_weight + config.rare_weight + config.epic_weight) {
            2
        } else {
            3
        }
    }

    fun get_power_range(rarity: u8): (u8, u8) {
        if (rarity == 0) {
            (1, 10)
        } else if (rarity == 1) {
            (11, 25)
        } else if (rarity == 2) {
            (26, 40)
        } else {
            (41, 50)
        }
    }

    fun generate_item_name(rarity: u8): String {
        if (rarity == 0) {
            string::utf8(b"Common Item")
        } else if (rarity == 1) {
            string::utf8(b"Rare Item")
        } else if (rarity == 2) {
            string::utf8(b"Epic Item")
        } else {
            string::utf8(b"Legendary Item")
        }
    }

    // --- Admin and Item Management ---

    /// Update loot drop generation chances. Can only be done via admin capabilities.
    public fun update_rarity_weights<T>(
        _admin: &AdminCap,
        config: &mut GameConfig<T>,
        common: u8,
        rare: u8,
        epic: u8,
        legendary: u8
    ) {
        assert!(common + rare + epic + legendary == 100, EInvalidWeights);
        config.common_weight = common;
        config.rare_weight = rare;
        config.epic_weight = epic;
        config.legendary_weight = legendary;
    }

    /// Read functionality - fetch statistics from an item struct point.
    public fun get_item_stats(item: &GameItem): (String, u8, u8) {
        (item.name, item.rarity, item.power)
    }

    /// Pass item ownership.
    public fun transfer_item(item: GameItem, recipient: address) {
        transfer::public_transfer(item, recipient);
    }

    /// Completely burn unwanted items.
    public fun burn_item(item: GameItem) {
        let GameItem { id, name: _, rarity: _, power: _ } = item;
        object::delete(id);
    }
}