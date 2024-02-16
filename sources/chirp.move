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

    /// Error code for minting not a whole number of tokens
    const EInvalidMintAmount: u64 = 1;

    // Liquidity pool for netwrok keepers
    const Keepers: address = @0x0e536a4f3cfd7f35533aa52a560dc0cae3e394bdad8dd27e1f9996284015a48e;

    // Liquidity pool for netwrok keepers growth
    const KeepersGrowth: address = @0x522366d83f5e03cf544ab02c1a2e2e60db2000af22e76c8ead22fb6eebdd0ae4;

    /// Liquidity pool for investors
    const Investors: address = @0xd831259f48614d134362fc60d1be6dc6988061d0758a1dece5066a329655cf84;

    /// Token treasury
    const TokenTreasury: address = @0x719a1df9e1f94b349e7888c4a378075b9a598b0e88e99cae63607abc3d9c40c4;

    /// Liquidity pool for CHIRP team
    const Team: address = @0x6b4f0f377d72cdeb5852c5b86b469566025fc3a74c166b25e05e617437e18b4c;

    /// Strategic advisors pool
    const StrategicAdvisors: address = @0x7f8496345a123fedbc9cbf19a9c1a4bcfa12281be277134fdceacda5d8e5f0d2;

    struct CHIRP has drop {}

    #[allow(unused_function)]
    /// Module initializer is called once on module publish. A mint
    /// cap is sent to the publisher, who then controls minting
    fun init(witness: CHIRP, ctx: &mut TxContext) {
        let (mintcap, metadata) = coin::create_currency(witness, CoinDecimals, CoinSymbol, CoinName, CoinDescription, option::none(), ctx);
        transfer::public_freeze_object(metadata);
        transfer::public_transfer(mintcap, tx_context::sender(ctx))
    }

    /// Mint tokens and transfer them to the pools according to the tokenomics
    public entry fun mint(mint_cap: &mut TreasuryCap<CHIRP>, amount: u64, ctx: &mut TxContext) {
        assert!(amount <= (MaximumSupply - coin::total_supply(mint_cap)), EMintLimitReached);
        // the amount must be the whole tokens
        assert!(amount % 10_000_000_000 == 0, EInvalidMintAmount);

        coin::mint_and_transfer(mint_cap, amount/100 * 30 , Keepers, ctx);
        coin::mint_and_transfer(mint_cap, amount/100 * 20 , KeepersGrowth, ctx);
        coin::mint_and_transfer(mint_cap, amount/100 * 15, Investors, ctx);
        coin::mint_and_transfer(mint_cap, amount/100 * 15, TokenTreasury, ctx);
        coin::mint_and_transfer(mint_cap, amount/100 * 15, Team, ctx);
        coin::mint_and_transfer(mint_cap, amount/100 * 5, StrategicAdvisors, ctx);
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
            // Network keepers pool should have 30% of the minted tokens
            let networkKeepersCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, Keepers);
            assert!(coin::value(&networkKeepersCoin) == tokensToMint/100 * 30, 1);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(Keepers, networkKeepersCoin);

            // Network keepers growth pool should have 20% of the minted tokens
            let keepersGrowthCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, KeepersGrowth);
            assert!(coin::value(&keepersGrowthCoin) == tokensToMint/100 * 20, 1);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(KeepersGrowth, keepersGrowthCoin);

            // Investors pool should have 15% of the mintet tokens
            let investorsCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, Investors);
            assert!(coin::value(&investorsCoin) == tokensToMint/100 * 15, 2);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(Investors, investorsCoin);

            // Token treasury pool should have 15% of the minted tokens
            let tokenTreasuryCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, TokenTreasury);
            assert!(coin::value(&tokenTreasuryCoin) == tokensToMint/100 * 15, 3);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(TokenTreasury, tokenTreasuryCoin);

            // Team pool should have 15% of the minted tokens
            let teamCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, Team);
            assert!(coin::value(&teamCoin) == tokensToMint/100 * 15, 4);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(Team, teamCoin);

            // Strategic advisors pool should have 5% of the minted tokens
            let strategicAdvisorsCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, StrategicAdvisors);
            assert!(coin::value(&strategicAdvisorsCoin) == tokensToMint/100 * 5, 5);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(StrategicAdvisors, strategicAdvisorsCoin);
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
