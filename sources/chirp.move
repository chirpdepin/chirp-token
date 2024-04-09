/// This module implements the CHIRP token, a custom token for the Chirp Network.
module blhnsuicntrtctkn::chirp {
    // === Imports ===
    use sui::coin::{Self, TreasuryCap};

    // === Errors ===

    #[allow(unused_const)]
    /// Error code for minting more tokens than allowed
    const EMintLimitReached: u64 = 0;

    // === Constants ===

    #[allow(unused_const)]
    /// Maximum supply of CHIRP tokens
    const MaximumSupply: u64 = 3000000000000000000u64;

    /// Decimals of CHIRP tokens
    const CoinDecimals: u8 = 10;

    /// Coin symbol in favor of ISO 4217
    const CoinSymbol: vector<u8> = b"CHIRP";

    /// Coin human readable name
    const CoinName: vector<u8> = b"Chirp Token";

    /// Coin human readable description
    const CoinDescription: vector<u8> = b"Chirp token description";

    // === Structs ===

    /// The one-time witness struct for the module
    public struct CHIRP has drop {}

    // === Functions ===

    fun init(otw: CHIRP, ctx: &mut TxContext) {
        let (mintcap, metadata) = coin::create_currency(
            otw,
            CoinDecimals,
            CoinSymbol,
            CoinName,
            CoinDescription, 
            option::none(), // No icon
            ctx,
        );
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(mintcap, tx_context::sender(ctx));
    }

    /// Mint new CHIRP coins according to the predefined schedule
    public entry fun mint(_: &mut TreasuryCap<CHIRP>, _ctx: &mut TxContext) {

    }


    #[test_only] use std::string;
    #[test_only] use sui::test_scenario;
    #[test_only] use sui::test_utils;
    #[test_only] const PUBLISHER: address = @0xA;

    #[test]
    fun test_init() {
        let mut scenario = test_scenario::begin(PUBLISHER);
        {
            init(CHIRP{}, test_scenario::ctx(&mut scenario));
        };
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            let metadata = test_scenario::take_immutable<coin::CoinMetadata<CHIRP>>(&scenario);
            let mintcap = test_scenario::take_from_sender<TreasuryCap<CHIRP>>(&scenario);
            test_utils::assert_eq(coin::get_decimals(&metadata), CoinDecimals);
            test_utils::assert_eq(string::index_of(&string::from_ascii(coin::get_symbol(&metadata)), &string::utf8(CoinSymbol)), 0);
            test_utils::assert_eq(string::index_of(&coin::get_name(&metadata), &string::utf8(CoinName)), 0);
            test_utils::assert_eq(string::index_of(&coin::get_description(&metadata), &string::utf8(CoinDescription)), 0);
            test_scenario::return_immutable<coin::CoinMetadata<CHIRP>>(metadata);
            test_scenario::return_to_address<TreasuryCap<CHIRP>>(PUBLISHER, mintcap);
        };
        test_scenario::end(scenario);
    }
}
