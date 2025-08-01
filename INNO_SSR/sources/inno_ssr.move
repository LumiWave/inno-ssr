// Copyright (c) PDX, Inc.
// SPDX-License-Identifier: Apache-2.0

module inno_ssr::SSR;

use sui::coin::{Self, Coin, TreasuryCap};
use sui::url;
use sui::pay;

const INIT_MAX_SUPPLY: u64 = 1_000_000_000_000_000_000;

public struct SSR has drop {}

public struct SupplyConfig has store, key {
    id: UID,
    max_supply: u64, 
    owner: address,
}

public struct ExtendedTreasuryCap has store, key {
    id: UID,
    treasury_cap: TreasuryCap<SSR>,
    current_supply: u64, 
    supply_config: SupplyConfig,
}

fun init(witness: SSR, ctx: &mut TxContext) {
    let (treasury_cap, deny_cap, metadata) = coin::create_regulated_currency_v2(
            witness, 
            9, 
            b"SSR", 
            b"Samurai Shodown R", 
            b"$SSR is a fungible token that connects various in-game and external activities in Samurai Shodown R by SNK. Through this token, players can enhance in-game growth elements, experience real asset ownership, and even participate in the ecosystem’s operation.", 
            option::some(url::new_unsafe_from_bytes(b"https://innofile.blob.core.windows.net/inno/live/icon/SSR_token_logo.png")), 
            false,
            ctx);
    transfer::public_freeze_object(metadata);

    let owner = tx_context::sender(ctx);
    let supply_config = SupplyConfig {
        id: object::new(ctx),
        max_supply: INIT_MAX_SUPPLY,
        owner,
    };

    let mut extened_treasure_cap = ExtendedTreasuryCap {
        id: object::new(ctx),
        treasury_cap,
        current_supply: INIT_MAX_SUPPLY,
        supply_config,
    };

    coin::mint_and_transfer<SSR>(&mut extened_treasure_cap.treasury_cap, INIT_MAX_SUPPLY, tx_context::sender(ctx), ctx);
    transfer::public_transfer(deny_cap, owner);
    transfer::public_transfer(extened_treasure_cap, owner);
}

public entry fun mint(extended_treasury_cap: &mut ExtendedTreasuryCap, amount: u64, ctx: &mut TxContext) {
    let new_supply = extended_treasury_cap.current_supply + amount;
    assert!(new_supply <= extended_treasury_cap.supply_config.max_supply, 1); // Check against max_supply in SupplyConfig.

    coin::mint_and_transfer(&mut extended_treasury_cap.treasury_cap, amount, tx_context::sender(ctx), ctx);
    extended_treasury_cap.current_supply = new_supply;
}

public entry fun burn(extended_treasury_cap: &mut ExtendedTreasuryCap, coin: Coin<SSR>) {
    let amount = coin::value(&coin);
    coin::burn(&mut extended_treasury_cap.treasury_cap, coin);
    extended_treasury_cap.current_supply = extended_treasury_cap.current_supply - amount;
}

public entry fun update_max_supply(extended_treasury_cap: &mut ExtendedTreasuryCap, new_max_supply: u64, ctx: &mut TxContext) {
    let sender = tx_context::sender(ctx);
    assert!(sender == extended_treasury_cap.supply_config.owner, 2); // Only the owner can update the max_supply.
    extended_treasury_cap.supply_config.max_supply = new_max_supply;
}

public entry fun transfer_bulk(mut input_coin: Coin<SSR>, recipients: vector<address>, amounts: vector<u64>, ctx: &mut TxContext) {
    let n = vector::length(&recipients);
    assert!(n == vector::length(&amounts), 100);

    // total sum
    let mut total: u64 = 0;
    let mut j = 0;
    while (j < n) {
        total = total + *vector::borrow(&amounts, j);
        j = j + 1;
    };

    // Verify that the current input_coin is sufficient
    assert!(coin::value(&input_coin) >= total, 3); // 3: Not enough quantity

    let mut i = 0;
    while (i < n) {
        let amount = *vector::borrow(&amounts, i);
        let send_coin = coin::split(&mut input_coin, amount, ctx);
        let recipient = *vector::borrow(&recipients, i);
        transfer::public_transfer(send_coin, recipient);
        
        i = i + 1;
    };

     pay::keep(input_coin, ctx);
}

public entry fun transfer_inno_protocol_reserve(mut coin : Coin<SSR>, amount: u64, recipient: address, ctx: &mut TxContext) {
    assert!(coin::value(&coin) >= amount, 4);

    let send_coin = coin::split(&mut coin, amount, ctx);
    transfer::public_transfer(send_coin, recipient);
    pay::keep(coin, ctx)
}

#[test_only]
public fun init_for_testing(ctx: &mut TxContext): u64 {
    init(SSR {}, ctx);
    INIT_MAX_SUPPLY
}
#[test_only]
public fun total_supply(extended_treasury_cap: &mut ExtendedTreasuryCap): u64 {
    coin::total_supply(&extended_treasury_cap.treasury_cap)
}
