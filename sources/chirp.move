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

    /// Liquidity pool for netwrok keepers
    const NetworkKeepers: address = @0xAA;

    /// Liquidity pool for investors
    const Investors: address = @0xBB;

    /// Token treasury
    const TokenTreasury: address = @0xCC;

    /// Liquidity pool for CHIRP team
    const Team: address = @0xDD;

    /// Strategic advisors pool
    const StrategicAdvisors: address = @0xEE;

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
        // the amaunt must be the whole tokens
        assert!(amount % 10_000_000_000 == 0, EInvalidMintAmount);

        coin::mint_and_transfer(mint_cap, amount/100 * 50 , NetworkKeepers, ctx);
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

        // Mint MaximumSupply tokens
        next_tx(&mut scenario, publisher);
        {
            let mintcap = test_scenario::take_from_sender<TreasuryCap<CHIRP>>(&scenario);
            mint(&mut mintcap, MaximumSupply, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_sender<TreasuryCap<CHIRP>>(&scenario, mintcap);
        };
        next_tx(&mut scenario, publisher);
        {
            // Network keepers pool should have 50% of the total supply
            let networkKeepersCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, NetworkKeepers);
            assert!(coin::value(&networkKeepersCoin) == MaximumSupply/100 * 50, 1);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(NetworkKeepers, networkKeepersCoin);

            // Investors pool should have 15% of the total supply
            let investorsCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, Investors);
            assert!(coin::value(&investorsCoin) == MaximumSupply/100 * 15, 2);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(Investors, investorsCoin);

            // Token treasury pool should have 15% of the total supply
            let tokenTreasuryCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, TokenTreasury);
            assert!(coin::value(&tokenTreasuryCoin) == MaximumSupply/100 * 15, 3);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(TokenTreasury, tokenTreasuryCoin);

            // Team pool should have 15% of the total supply
            let teamCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, Team);
            assert!(coin::value(&teamCoin) == MaximumSupply/100 * 15, 4);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(Team, teamCoin);

            // Strategic advisors pool should have 5% of the total supply
            let strategicAdvisorsCoin = test_scenario::take_from_address<coin::Coin<CHIRP>>(&scenario, StrategicAdvisors);
            assert!(coin::value(&strategicAdvisorsCoin) == MaximumSupply/100 * 5, 5);
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
