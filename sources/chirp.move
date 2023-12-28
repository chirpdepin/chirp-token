module blhnsuicntrtctkn::chirp {
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};

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

    /// Error code for minting more tokens than allowed
    const EMintLimitReached: u64 = 0;

    struct CHIRP has drop {}

    #[allow(unused_function)]
    /// Module initializer is called once on module publish. A mint
    /// cap is sent to the publisher, who then controls minting
    fun init(witness: CHIRP, ctx: &mut TxContext) {
        let (mintcap, metadata) = coin::create_currency(witness, CoinDecimals, CoinSymbol, CoinName, CoinDescription, option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(mintcap, tx_context::sender(ctx))
    }

    /// Mint tokens to the recipient
    public entry fun mint(mint_cap: &mut TreasuryCap<CHIRP>, amount: u64, recipient: address, ctx: &mut TxContext) {
        assert!(amount <= (MaximumSupply - coin::total_supply(mint_cap)), EMintLimitReached);
        coin::mint_and_transfer(mint_cap, amount, recipient, ctx)
    }

    #[test_only]
    use sui::test_scenario::{Self, next_tx, ctx};
    #[test_only]
    use std::string;

    #[test_only]
    /// Wrapper of module initializer for testing
    public fun test_init(ctx: &mut TxContext) {
        init(CHIRP{}, ctx)
    }

    #[test]
    fun currency_creation() {
        // Initialize a mock sender address
        let publisher = @0xA;

        // Begins a multi transaction scenario with publisher as the sender
        let scenario = test_scenario::begin(publisher);

        // Run the chirp coin module init function
        {
            test_init(ctx(&mut scenario))
        };
        next_tx(&mut scenario, publisher);
        {
            let metadata = test_scenario::take_immutable<coin::CoinMetadata<CHIRP>>(&scenario);
            let mintcap = test_scenario::take_from_sender<TreasuryCap<CHIRP>>(&scenario);
            assert!(coin::get_decimals(&metadata) == CoinDecimals, 1);
            assert!(string::index_of(&string::from_ascii(coin::get_symbol(&metadata)), &string::utf8(CoinSymbol)) == 0, 2);
            assert!(string::index_of(&coin::get_name(&metadata), &string::utf8(CoinName)) == 0, 3);
            assert!(string::index_of(&coin::get_description(&metadata), &string::utf8(CoinDescription)) == 0, 4);
            assert!(coin::total_supply(&mintcap) == 0, 5);
            test_scenario::return_immutable<coin::CoinMetadata<CHIRP>>(metadata);
            test_scenario::return_to_address<TreasuryCap<CHIRP>>(publisher, mintcap);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun mint_normal() {
        // Initialize a mock sender address
        let publisher = @0xA;
        let pool = @0xB;

        // Begins a multi transaction scenario with publisher as the sender
        let scenario = test_scenario::begin(publisher);

        // Run the chirp coin module init function
        {
            test_init(ctx(&mut scenario))
        };

        // Mint a `Coin<CHIRP>` object
        next_tx(&mut scenario, publisher);
        {
            let mintcap = test_scenario::take_from_sender<TreasuryCap<CHIRP>>(&scenario);
            mint(&mut mintcap, MaximumSupply, pool, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_address<TreasuryCap<CHIRP>>(publisher, mintcap);
        };
        next_tx(&mut scenario, pool);
        {
            let coin = test_scenario::take_from_sender<coin::Coin<CHIRP>>(&scenario);
            assert!(coin::value(&coin) == MaximumSupply, 1);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(pool, coin);
        };

        // Cleans up the scenario object
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = EMintLimitReached)]
    fun mint_limit_reached() {
        // Initialize a mock sender address
        let publisher = @0xA;
        // Begins a multi transaction scenario with publisher as the sender
        let scenario = test_scenario::begin(publisher);

        // Run the chirp coin module init function
        {
            test_init(ctx(&mut scenario))
        };
        // Mint a `Coin<CHIRP>` object
        next_tx(&mut scenario, publisher);
        {
            let mintcap = test_scenario::take_from_sender<TreasuryCap<CHIRP>>(&scenario);
            mint(&mut mintcap, MaximumSupply + 1, publisher, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_address<TreasuryCap<CHIRP>>(publisher, mintcap);
        };

        // Cleans up the scenario object
        test_scenario::end(scenario);
    }
}
