module blhnsuicntrtctkn::chirp {
    use std::option;
    use sui::coin::{Self, TreasuryCap};
    use sui::transfer;
    use sui::tx_context::{Self, TxContext};
    use sui::url;

    /// Maximum supply of CHIRP tokens
    const MaximumSupply: u64 = 3000000000000000000u64;

    /// Decimals of CHIRP tokens
    const CoinDecimals: u8 = 10;

    /// Coin symbol in favor of ISO 4217
    const CoinSymbol: vector<u8> = b"CHIRP";

    /// Coin icon
    const CoinIcon: vector<u8> = b"https://storage.googleapis.com/chirp-blhn-assets/images/CHIRP_White_OBG.svg";

    /// Coin human readable name
    const CoinName: vector<u8> = b"Chirp Token";

    /// Coin human readable description
    const CoinDescription: vector<u8> = b"Chirp token description";

    /// Error code for minting more tokens than allowed
    const EMintLimitReached: u64 = 0;

    /// Error code for minting not a whole number of tokens
    const EInvalidMintAmount: u64 = 1;

    // Liquidity pool for netwrok keepers
    const Keepers: address = @0x02ab60f0e82d58cbd047dd27d9e09d08a9b41d8d08f2f08bd0f25424d08c7f77;

    // Liquidity pool for netwrok keepers growth
    const KeepersGrowth: address = @0x021e2fcdb57234a42a588654bc2b31fa1a53896cdc11b81d9332a5287cd0f248;

    /// Liquidity pool for investors
    const Investors: address = @0x6bf9e238beb4391690ec02ce41cb480f91a78178819574bf6e9882cc238920d3;

    /// Token treasury
    const TokenTreasury: address = @0xc196c590ff20d63d17271c8dcceafc3432a47f629292fa9f552f5c8c4ea92b4b;

    #[allow(unused_const)]
    /// Liquidity pool for CHIRP team
    const Team: address = @0xd841709b605bafdcb27d544b0a76e35cd3e904a6b6f5b4347e836c1dd24f6306;

    #[allow(unused_const)]
    /// Strategic advisors pool
    const StrategicAdvisors: address = @0x573a0841ab7c22c1e5c714c4e5ab1c440546c8c36c2b94eba62665c5f75237d6;

    // Liquidity pool
    const Liquidity: address = @0x9575fc19fedcd62a406385dcc7607c567d91a6df94e2eea9a941051bbb6ce65e;

    struct CHIRP has drop {}

    #[allow(unused_function)]
    /// Module initializer is called once on module publish. A mint
    /// cap is sent to the publisher, who then controls minting
    fun init(witness: CHIRP, ctx: &mut TxContext) {
        let (mintcap, metadata) = coin::create_currency(witness, CoinDecimals, CoinSymbol, CoinName, CoinDescription, option::some(url::new_unsafe_from_bytes(CoinIcon)), ctx);
        transfer::public_freeze_object(metadata);

        // Pre-mint the tokens and transfer them to the pools
        coin::mint_and_transfer(&mut mintcap, 9_000_000_0000000000, Investors, ctx);
        coin::mint_and_transfer(&mut mintcap, 3_300_000_0000000000, TokenTreasury, ctx);
        coin::mint_and_transfer(&mut mintcap, 12_000_000_0000000000, Liquidity, ctx);

        transfer::public_transfer(mintcap, tx_context::sender(ctx));
    }

    /// Mint tokens and transfer them to the pools according to the tokenomics
    public entry fun mint(mint_cap: &mut TreasuryCap<CHIRP>, cents: u64, ctx: &mut TxContext) {
        assert!(cents <= (MaximumSupply - coin::total_supply(mint_cap)), EMintLimitReached);
        // the amount must be the whole tokens
        assert!(cents % 10_000_000_000 == 0, EInvalidMintAmount);

        let amount = cents/10_000_000_000;
        coin::mint_and_transfer(mint_cap, amount * 1903222709, Keepers, ctx);
        coin::mint_and_transfer(mint_cap, amount * 1280122892 , KeepersGrowth, ctx);
        coin::mint_and_transfer(mint_cap, amount * 5760553013 , Investors, ctx);
        coin::mint_and_transfer(mint_cap, amount * 1056101386, TokenTreasury, ctx);
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

            // Investors pool should have 9.000.000 tokens pre-minted
            let investors = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, Investors);
            assert!(coin::value(&investors) == 9_000_000_0000000000, 5);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(Investors, investors);

            // Treasury pool should have 3.300.000 tokens pre-minted
            let tokenTreasury = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, TokenTreasury);
            assert!(coin::value(&tokenTreasury) == 3_300_000_0000000000, 6);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(TokenTreasury, tokenTreasury);

            // Liquidity pool should have 12.000.000 tokens pre-minted
            let liquidity = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, Liquidity);
            assert!(coin::value(&liquidity) == 12_000_000_0000000000, 7);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(Liquidity, liquidity);

            test_scenario::return_immutable<coin::CoinMetadata<CHIRP>>(metadata);
            test_scenario::return_to_address<TreasuryCap<CHIRP>>(publisher, mintcap);
        };

        test_scenario::end(scenario);
    }

    #[test]
    fun mint_normal() {
        let publisher = @0xA;
        let scenario = test_scenario::begin(publisher);
        {
            test_init(ctx(&mut scenario))
        };

        let tokensToMint: u64 = 10_000_000_000;

        // Mint `tokensToMint` tokens
        next_tx(&mut scenario, publisher);
        {
            let mintcap = test_scenario::take_from_sender<TreasuryCap<CHIRP>>(&scenario);
            mint(&mut mintcap, tokensToMint, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender<TreasuryCap<CHIRP>>(&scenario, mintcap);
        };
        next_tx(&mut scenario, publisher);
        {
            // Network keepers pool should have 19.03222709% of the minted tokens
            let networkKeepersCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, Keepers);
            assert!(coin::value(&networkKeepersCoin) == tokensToMint/10_000_000_000 * 1903222709, 1);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(Keepers, networkKeepersCoin);

            // Network keepers growth pool should have 12.80122892% of the minted tokens
            let keepersGrowthCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, KeepersGrowth);
            assert!(coin::value(&keepersGrowthCoin) == tokensToMint/10_000_000_000 * 1280122892, 1);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(KeepersGrowth, keepersGrowthCoin);

            // Investors pool should have 57.60553013% of the minted tokens
            let investorsCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, Investors);
            assert!(coin::value(&investorsCoin) == tokensToMint/10_000_000_000 * 5760553013,  2);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(Investors, investorsCoin);

            // Token treasury pool should have 10.56101386% of the minted tokens
            let tokenTreasuryCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, TokenTreasury);
            assert!(coin::value(&tokenTreasuryCoin) == tokensToMint/10_000_000_000 * 1056101386, 3);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(TokenTreasury, tokenTreasuryCoin);
        };
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = EMintLimitReached)]
    fun mint_limit_reached() {
        let publisher = @0xA;
        let scenario = test_scenario::begin(publisher);
        {
            test_init(ctx(&mut scenario))
        };
        // Mint more than MaximumSupply tokens
        next_tx(&mut scenario, publisher);
        {
            let mintcap = test_scenario::take_from_sender<TreasuryCap<CHIRP>>(&scenario);
            mint(&mut mintcap, MaximumSupply + 10_000_000_000, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender<TreasuryCap<CHIRP>>(&scenario, mintcap);
        };
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = EInvalidMintAmount)]
    fun mint_invalid_amount() {
        let publisher = @0xA;
        let scenario = test_scenario::begin(publisher);
        {
            test_init(ctx(&mut scenario))
        };
        // Mint amount of tokens that is not a whole number
        next_tx(&mut scenario, publisher);
        {
            let mintcap = test_scenario::take_from_sender<TreasuryCap<CHIRP>>(&scenario);
            mint(&mut mintcap, 100, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender<TreasuryCap<CHIRP>>(&scenario, mintcap);
        };
        test_scenario::end(scenario);
    }
}
