/// This module implements the CHIRP token, a custom token for the Chirp Network.
module blhnsuicntrtctkn::chirp {
    // === Imports ===
    use blhnsuicntrtctkn::schedule::{Self};
    use blhnsuicntrtctkn::treasury::{Self, Treasury};
    use sui::clock::{Clock};
    use sui::coin::{Self};

    // === Constants ===
    /// Decimals of CHIRP tokens
    const COIN_DECIMALS: u8 = 10;
    /// Coin human readable description
    const COIN_DESCRIPTION: vector<u8> = b"Chirp token description";
    /// Coin human readable name
    const COIN_NAME: vector<u8> = b"Chirp Token";
    /// Coin symbol in favor of ISO 4217
    const COIN_SYMBOL: vector<u8> = b"CHIRP";

    // === Structs ===
    /// The one-time witness struct for the module
    public struct CHIRP has drop {}

    // === Functions ===
    /// Creates the CHIRP token and initializes the minting schedule
    fun init(otw: CHIRP, ctx: &mut TxContext) {
        let (coin_treasury_cap, metadata) = coin::create_currency(
            otw,
            COIN_DECIMALS,
            COIN_SYMBOL,
            COIN_NAME,
            COIN_DESCRIPTION,
            option::none(), // No icon
            ctx,
        );
        transfer::public_freeze_object(metadata);
        let admin_cap = treasury::create(coin_treasury_cap, schedule::default(), ctx);
        transfer::public_transfer(admin_cap, ctx.sender());
    }

    /// Mint new CHIRP coins according to the predefined schedule
    public entry fun mint(treasury: &mut Treasury<CHIRP>, clock: &Clock, ctx: &mut TxContext) {
        treasury::mint(treasury, clock, ctx);
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(CHIRP{}, ctx)
    }

    #[test_only] public fun coin_decimals(): u8 { COIN_DECIMALS }
    #[test_only] public fun coin_description(): vector<u8> { COIN_DESCRIPTION }
    #[test_only] public fun coin_name(): vector<u8> { COIN_NAME }
    #[test_only] public fun coin_symbol(): vector<u8> { COIN_SYMBOL }
}

#[test_only]
module blhnsuicntrtctkn::chirp_tests {
    use blhnsuicntrtctkn::chirp::{Self, CHIRP};
    use std::string;
    use sui::coin::{Self};
    use sui::test_scenario;
    use sui::test_utils;

    const PUBLISHER: address = @0xA;

    #[test]
    fun test_currency_creation() {
        let mut scenario = test_scenario::begin(PUBLISHER);
        {
            chirp::init_for_testing(scenario.ctx()); 
        };
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            let metadata = test_scenario::take_immutable<coin::CoinMetadata<CHIRP>>(&scenario);
            test_utils::assert_eq(coin::get_decimals(&metadata), chirp::coin_decimals());
            test_utils::assert_eq(string::index_of(&string::from_ascii(metadata.get_symbol()), &string::utf8(chirp::coin_symbol())), 0);
            test_utils::assert_eq(string::index_of(&metadata.get_name(), &string::utf8(chirp::coin_name())), 0);
            test_utils::assert_eq(string::index_of(&metadata.get_description(), &string::utf8(chirp::coin_description())), 0);
            test_scenario::return_immutable<coin::CoinMetadata<CHIRP>>(metadata);
        };
        test_scenario::end(scenario);
    }
}
