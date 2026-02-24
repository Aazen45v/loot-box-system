#[test_only]
module loot_box::loot_box_tests {
    use sui::test_scenario::{Self, Scenario};
    use sui::coin;
    use sui::sui::SUI;
    use sui::random;

    use loot_box::loot_box::{Self, GameConfig, LootBox, GameItem, AdminCap};

    // Users
    const ADMIN: address = @0xA;
    const USER1: address = @0xB;
    const USER2: address = @0xC;

    #[test]
    fun test_init_game() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        // Let's init game as Admin
        loot_box::init_game<SUI>(test_scenario::ctx(&mut scenario));
        
        test_scenario::next_tx(&mut scenario, ADMIN);
        
        let config_val = test_scenario::take_shared<GameConfig<SUI>>(&scenario);
        let admin_cap_val = test_scenario::take_from_sender<AdminCap>(&scenario);
        
        test_scenario::return_shared(config_val);
        test_scenario::return_to_sender(&scenario, admin_cap_val);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_purchase_loot_box() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        loot_box::init_game<SUI>(test_scenario::ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER1);

        let mut config = test_scenario::take_shared<GameConfig<SUI>>(&scenario);
        
        // Purchase
        let payment = coin::mint_for_testing<SUI>(1000, test_scenario::ctx(&mut scenario));
        let loot_box = loot_box::purchase_loot_box(&mut config, payment, test_scenario::ctx(&mut scenario));
        
        transfer::public_transfer(loot_box, USER1);
        
        test_scenario::next_tx(&mut scenario, USER1);
        
        let owned_box = test_scenario::take_from_sender<LootBox>(&scenario);
        transfer::public_transfer(owned_box, USER1); // put it back
        
        test_scenario::return_shared(config);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = loot_box::loot_box::EInsufficientPayment)]
    fun test_purchase_insufficient_payment() {
        let mut scenario = test_scenario::begin(ADMIN);
        
        loot_box::init_game<SUI>(test_scenario::ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER1);

        let mut config = test_scenario::take_shared<GameConfig<SUI>>(&scenario);
        
        // Attempt to Purchase with 500 SUI (less than the 1000 price)
        let payment = coin::mint_for_testing<SUI>(500, test_scenario::ctx(&mut scenario));
        let loot_box = loot_box::purchase_loot_box(&mut config, payment, test_scenario::ctx(&mut scenario));
        
        transfer::public_transfer(loot_box, USER1);
        
        test_scenario::return_shared(config);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_open_loot_box() {
        let mut scenario = test_scenario::begin(ADMIN);
        random::create_for_testing(test_scenario::ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, ADMIN);
        
        loot_box::init_game<SUI>(test_scenario::ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER1);

        let mut config = test_scenario::take_shared<GameConfig<SUI>>(&scenario);
        
        // Purchase
        let payment = coin::mint_for_testing<SUI>(1000, test_scenario::ctx(&mut scenario));
        let loot_box = loot_box::purchase_loot_box(&mut config, payment, test_scenario::ctx(&mut scenario));
        
        // Note: we can't test random actual output values deterministicly without randomness mock helpers. 
        // We will execute the function to confirm no panic crashes.
        let mut random_state = test_scenario::take_shared<random::Random>(&scenario);
        
        // Must update randomness before use
        random::update_randomness_state_for_testing(
            &mut random_state,
            1,
            x"00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF",
            test_scenario::ctx(&mut scenario),
        );
        
        loot_box::open_loot_box(&mut config, loot_box, &random_state, test_scenario::ctx(&mut scenario));
        
        test_scenario::next_tx(&mut scenario, USER1);
        
        let generated_item = test_scenario::take_from_sender<GameItem>(&scenario);
        
        let (_name, rarity, _power) = loot_box::get_item_stats(&generated_item);
        // Ensure valid rarity
        assert!(rarity <= 3, 0); 
        
        transfer::public_transfer(generated_item, USER1); // returning it back
        test_scenario::return_shared(config);
        test_scenario::return_shared(random_state);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_transfer_item() {
        let mut scenario = test_scenario::begin(ADMIN);
        random::create_for_testing(test_scenario::ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, ADMIN);

        loot_box::init_game<SUI>(test_scenario::ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER1);
        
        let mut config = test_scenario::take_shared<GameConfig<SUI>>(&scenario);
        let payment = coin::mint_for_testing<SUI>(1000, test_scenario::ctx(&mut scenario));
        let loot_box = loot_box::purchase_loot_box(&mut config, payment, test_scenario::ctx(&mut scenario));
        
        let mut random_state = test_scenario::take_shared<random::Random>(&scenario);
        random::update_randomness_state_for_testing(
            &mut random_state,
            1,
            x"00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF",
            test_scenario::ctx(&mut scenario),
        );
        loot_box::open_loot_box(&mut config, loot_box, &random_state, test_scenario::ctx(&mut scenario));
        
        test_scenario::next_tx(&mut scenario, USER1);
        let item_to_transfer = test_scenario::take_from_sender<GameItem>(&scenario);
        
        loot_box::transfer_item(item_to_transfer, USER2);
        
        test_scenario::next_tx(&mut scenario, USER2);
        let item_owned_by_user2 = test_scenario::take_from_sender<GameItem>(&scenario);
        transfer::public_transfer(item_owned_by_user2, USER2);

        test_scenario::return_shared(config);
        test_scenario::return_shared(random_state);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_burn_item() {
        let mut scenario = test_scenario::begin(ADMIN);
        random::create_for_testing(test_scenario::ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, ADMIN);

        loot_box::init_game<SUI>(test_scenario::ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, USER1);
        
        let mut config = test_scenario::take_shared<GameConfig<SUI>>(&scenario);
        let payment = coin::mint_for_testing<SUI>(1000, test_scenario::ctx(&mut scenario));
        let loot_box = loot_box::purchase_loot_box(&mut config, payment, test_scenario::ctx(&mut scenario));
        
        let mut random_state = test_scenario::take_shared<random::Random>(&scenario);
        random::update_randomness_state_for_testing(
            &mut random_state,
            1,
            x"00112233445566778899AABBCCDDEEFF00112233445566778899AABBCCDDEEFF",
            test_scenario::ctx(&mut scenario),
        );
        loot_box::open_loot_box(&mut config, loot_box, &random_state, test_scenario::ctx(&mut scenario));
        
        test_scenario::next_tx(&mut scenario, USER1);
        let item_to_burn = test_scenario::take_from_sender<GameItem>(&scenario);
        
        loot_box::burn_item(item_to_burn);

        test_scenario::return_shared(config);
        test_scenario::return_shared(random_state);
        test_scenario::end(scenario);
    }

    #[test]
    fun test_update_rarity_weights() {
        let mut scenario = test_scenario::begin(ADMIN);
        loot_box::init_game<SUI>(test_scenario::ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, ADMIN);

        let mut config = test_scenario::take_shared<GameConfig<SUI>>(&scenario);
        let admin_cap = test_scenario::take_from_sender<AdminCap>(&scenario);

        // Update weights
        loot_box::update_rarity_weights(&admin_cap, &mut config, 50, 30, 15, 5);

        test_scenario::return_shared(config);
        test_scenario::return_to_sender(&scenario, admin_cap);
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = loot_box::loot_box::EInvalidWeights)]
    fun test_update_weights_invalid_sum() {
         let mut scenario = test_scenario::begin(ADMIN);
        loot_box::init_game<SUI>(test_scenario::ctx(&mut scenario));
        test_scenario::next_tx(&mut scenario, ADMIN);

        let mut config = test_scenario::take_shared<GameConfig<SUI>>(&scenario);
        let admin_cap = test_scenario::take_from_sender<AdminCap>(&scenario);

        // Update weights causing sum to be invalid (not 100)
        loot_box::update_rarity_weights(&admin_cap, &mut config, 50, 50, 15, 5);

        test_scenario::return_shared(config);
        test_scenario::return_to_sender(&scenario, admin_cap);
        test_scenario::end(scenario);
    }
}