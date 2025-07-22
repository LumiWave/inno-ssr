#[test_only]
module inno_ssr::SSR_coin_tests;

    use sui::test_scenario;
    use sui::coin::{Self, Coin, DenyCapV2};
    use inno_ssr::SSR::{SSR, ExtendedTreasuryCap};

    // Additional minting test after initial minting
    #[test_only]
    public fun test_mint() {
        let user = @0xA;
        let mut amount = 900_000_000_000_000_000;
        let mut scenario_val = test_scenario::begin(user);
        let scenario = &mut scenario_val;
        {
            let ctx = test_scenario::ctx(scenario);
            inno_ssr::SSR::init_for_testing(ctx);
        };
        test_scenario::next_tx(scenario, user);
        {
            let coin = test_scenario::take_from_sender<Coin<SSR>>(scenario);
            assert!(coin::value(&coin) == amount, 1);

            let deny_cap = test_scenario::take_from_sender<DenyCapV2<SSR>>(scenario);
            let mut treasury_cap = test_scenario::take_from_sender<ExtendedTreasuryCap>(scenario);   
            assert!(inno_ssr::SSR::total_supply(&mut treasury_cap) == amount, 1);

            // minting
            let ctx = test_scenario::ctx(scenario);
            inno_ssr::SSR::mint(&mut treasury_cap, 1000, ctx);
            amount = amount + 1000;
            assert!(inno_ssr::SSR::total_supply(&mut treasury_cap) == amount, 1);
            // Create Forced Error
            // inno_ssr::SSR::::mint(&mut treasury_cap, amount, user, test_scenario::ctx(scenario)); 

            test_scenario::return_to_sender(scenario, coin);
            test_scenario::return_to_sender(scenario, treasury_cap);
            test_scenario::return_to_sender(scenario, deny_cap);

        };
        test_scenario::end(scenario_val);
    }
