/// This module implements the CHIRP token, a custom token for the Chirp Network.
module blhnsuicntrtctkn::chirp {
    // === Imports ===
    use blhnsuicntrtctkn::schedule::{Self};
    use blhnsuicntrtctkn::treasury::{Self, ScheduleAdminCap, Treasury};
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

    /// Replace the schedule entry
    public entry fun set_entry(
        _: &ScheduleAdminCap,
        treasury: &mut Treasury<CHIRP>, 
        index: u64,
        pools: vector<address>,
        amounts: vector<u64>,
        number_of_epochs: u64,
        epoch_duration_ms: u64,
        timeshift_ms: Option<u64>,
    ) {
        let entry = treasury::create_entry<CHIRP>(pools, amounts, number_of_epochs, epoch_duration_ms, timeshift_ms);
        treasury.set_entry(index, entry)
    }

    /// Insert the schedule entry before the specified index
    public entry fun insert_entry(
        _: &ScheduleAdminCap,
        treasury: &mut Treasury<CHIRP>, 
        index: u64,
        pools: vector<address>,
        amounts: vector<u64>,
        number_of_epochs: u64,
        epoch_duration_ms: u64,
        timeshift_ms: Option<u64>,
    ) {
        let entry = treasury::create_entry<CHIRP>(pools, amounts, number_of_epochs, epoch_duration_ms, timeshift_ms);
        treasury.insert_entry(index, entry)
    }

    /// Remove the schedule entry at the specified index
    public entry fun remove_entry(_: &ScheduleAdminCap, treasury: &mut Treasury<CHIRP>, index: u64) {
        treasury.remove_entry(index);
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
    use blhnsuicntrtctkn::treasury::{ScheduleAdminCap, Treasury};
    use std::string;
    use sui::clock::{Self, Clock};
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
        scenario.next_tx(PUBLISHER);
        {
            let metadata = test_scenario::take_immutable<coin::CoinMetadata<CHIRP>>(&scenario);
            test_utils::assert_eq(coin::get_decimals(&metadata), chirp::coin_decimals());
            test_utils::assert_eq(string::index_of(&string::from_ascii(metadata.get_symbol()), &string::utf8(chirp::coin_symbol())), 0);
            test_utils::assert_eq(string::index_of(&metadata.get_name(), &string::utf8(chirp::coin_name())), 0);
            test_utils::assert_eq(string::index_of(&metadata.get_description(), &string::utf8(chirp::coin_description())), 0);
            test_scenario::return_immutable(metadata);
        };
        scenario.end();
    }

    #[test]
    fun test_set_entry_allows_to_modify_default_schedule()
    {
        let mut scenario = test_scenario::begin(PUBLISHER);
        {
            chirp::init_for_testing(scenario.ctx());
            clock::share_for_testing(clock::create_for_testing(scenario.ctx()));
        };
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<CHIRP> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            let cap: ScheduleAdminCap = test_scenario::take_from_sender(&scenario);

            // Setting zero mint params
            chirp::set_entry(&cap, &mut treasury, 0, vector[PUBLISHER], vector[1000], 1, 1000, option::none());
            chirp::mint(&mut treasury, &clock, scenario.ctx());

            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
            test_scenario::return_to_sender(&scenario, cap);
        };
        scenario.next_tx(PUBLISHER);
        {
            assert_eq_chirp_coin(PUBLISHER, 1000, &scenario);
        };
        scenario.end();
    }

    #[test]
    fun test_insert_entry_allows_add_new_entries_into_default_schedule()
    {
        let mut scenario = test_scenario::begin(PUBLISHER);
        {
            chirp::init_for_testing(scenario.ctx());
            clock::share_for_testing(clock::create_for_testing(scenario.ctx()));
        };
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<CHIRP> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            let cap: ScheduleAdminCap = test_scenario::take_from_sender(&scenario);

            // inserting new zero mint stage
            chirp::insert_entry(&cap, &mut treasury, 0, vector[PUBLISHER], vector[1000], 1, 1000, option::none());
            chirp::mint(&mut treasury, &clock, scenario.ctx());

            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
            test_scenario::return_to_sender(&scenario, cap);
        };
        scenario.next_tx(PUBLISHER);
        {
            assert_eq_chirp_coin(PUBLISHER, 1000, &scenario);
        };
        scenario.end();
    }

    #[test]
    fun test_remove_entry_allows_to_remove_entries_from_default_schedule()
    {
        let mut scenario = test_scenario::begin(PUBLISHER);
        {
            chirp::init_for_testing(scenario.ctx());
            clock::share_for_testing(clock::create_for_testing(scenario.ctx()));
        };
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<CHIRP> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            let cap: ScheduleAdminCap = test_scenario::take_from_sender(&scenario);

            chirp::insert_entry(&cap, &mut treasury, 0, vector[PUBLISHER], vector[1000], 1, 1000, option::none());
            chirp::insert_entry(&cap, &mut treasury, 1, vector[PUBLISHER], vector[3117], 1, 1000, option::none());
            // removing first mint stage
            chirp::remove_entry(&cap, &mut treasury, 0);

            // Should mint 3117 coins
            chirp::mint(&mut treasury, &clock, scenario.ctx());

            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
            test_scenario::return_to_sender(&scenario, cap);
        };
        scenario.next_tx(PUBLISHER);
        {
            assert_eq_chirp_coin(PUBLISHER, 3117, &scenario);
        };
        scenario.end();
    }

    /// Asserts that the value of the CHIRP coin held by the owner is equal to the expected value.
    fun assert_eq_chirp_coin(owner: address, expected_value: u64, scenario: &test_scenario::Scenario) {
        test_utils::assert_eq(total_coins(owner, scenario), expected_value);
    }

    /// Returns the total value of the test coins held by the owner.
    fun total_coins(owner: address, scenario: &test_scenario::Scenario): u64 {
        let coin_ids = test_scenario::ids_for_address<coin::Coin<CHIRP>>(owner);
        let mut i = 0;
        let mut total = 0;
        while (i < coin_ids.length()) {
            let coin = test_scenario::take_from_address_by_id<coin::Coin<CHIRP>>(scenario, owner, coin_ids[i]);
            total = total + coin::value(&coin);
            test_scenario::return_to_address<coin::Coin<CHIRP>>(owner, coin);
            i = i + 1;
        };
        total
    }
}
