#[test_only]
module inno_ssr::SSR_coin_tests;

use sui::test_scenario;
use sui::coin::{Self, Coin, DenyCapV2};
use inno_ssr::SSR::{SSR, ExtendedTreasuryCap, transfer_bulk, transfer_inno_protocol_reserve};

// Additional minting test after initial minting
#[test]
public fun test_mint_update_max_supply() {
    let user = @0xA;
    let mut amount = 1_000_000_000_000_000_000;
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

        let ctx = test_scenario::ctx(scenario);
        // update max supply
        inno_ssr::SSR::update_max_supply(&mut treasury_cap, amount + 1000, ctx);

        // minting
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

#[test]
public fun test_burn(){
    let user = @0xA;
    let mut amount = 1_000_000_000_000_000_000;
    let mut scenario_val = test_scenario::begin(user);
    let scenario = &mut scenario_val;
    {
        let ctx = test_scenario::ctx(scenario);
        inno_ssr::SSR::init_for_testing(ctx);
    };
    test_scenario::next_tx(scenario, user);
    {
        let mut coin_ssr = test_scenario::take_from_sender<Coin<SSR>>(scenario);
        assert!(coin::value(&coin_ssr) == amount, 1);

        let deny_cap = test_scenario::take_from_sender<DenyCapV2<SSR>>(scenario);
        let mut treasury_cap = test_scenario::take_from_sender<ExtendedTreasuryCap>(scenario);   
        assert!(inno_ssr::SSR::total_supply(&mut treasury_cap) == amount, 1);

        // burn
        let ctx = test_scenario::ctx(scenario);
        let coin_split = coin::split(&mut coin_ssr, 1000, ctx);
        inno_ssr::SSR::burn(&mut treasury_cap, coin_split);
        amount = amount - 1000;
        assert!(inno_ssr::SSR::total_supply(&mut treasury_cap) == amount, 1);

        test_scenario::return_to_sender(scenario, coin_ssr);
        test_scenario::return_to_sender(scenario, treasury_cap);
        test_scenario::return_to_sender(scenario, deny_cap);

    };
    test_scenario::end(scenario_val);
}

#[test]
public fun test_bulk_transfer() {
    let user = @0xA;
    let receiver1 = @0xB;
    let receiver2 = @0xC;
    let receiver3 = @0xD;

    let amount = 1_000_000_000_000_000_000;
    let mut scenario_val = test_scenario::begin(user);
    let scenario = &mut scenario_val;
    {
        let ctx = test_scenario::ctx(scenario);
        inno_ssr::SSR::init_for_testing(ctx);
    };
    test_scenario::next_tx(scenario, user);
    {
        let mut coin_ssr = test_scenario::take_from_sender<Coin<SSR>>(scenario);
        assert!(coin::value(&coin_ssr) == amount, 1);

        let mut recipients = vector::empty<address>();
        recipients.push_back(receiver1);
        recipients.push_back(receiver2);
        recipients.push_back(receiver3);

        let mut amounts = vector::empty();
        amounts.push_back(1000);
        amounts.push_back(2000);
        amounts.push_back(3000);

        let ctx = test_scenario::ctx(scenario);
        let coin_split = coin::split(&mut coin_ssr, 6000, ctx);
        transfer_bulk(coin_split, recipients, amounts, ctx);

        test_scenario::return_to_sender(scenario, coin_ssr);
    };
    test_scenario::end(scenario_val);
}

#[test]
public fun test_transfer_inno_protocol_reserve() {
    let user = @0xA;
    let receiver1 = @0xB;

    let amount = 1_000_000_000_000_000_000;
    let mut scenario_val = test_scenario::begin(user);
    let scenario = &mut scenario_val;
    {
        let ctx = test_scenario::ctx(scenario);
        inno_ssr::SSR::init_for_testing(ctx);
    };
    test_scenario::next_tx(scenario, user);
    {
        let mut coin_up = test_scenario::take_from_sender<Coin<SSR>>(scenario);
        assert!(coin::value(&coin_up) == amount, 1);

        let ctx = test_scenario::ctx(scenario);
        let coin_split = coin::split(&mut coin_up, 1000000000, ctx);
        transfer_inno_protocol_reserve(coin_split, 1000000000, receiver1, ctx);

        //test_scenario::return_to_sender(scenario, coin_split);
        test_scenario::return_to_sender(scenario, coin_up);
    };
    test_scenario::end(scenario_val);
}