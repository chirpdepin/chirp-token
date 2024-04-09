/// This module implements scheduled minting mechanics for the coin.
module blhnsuicntrtctkn::treasury {
    // === Imports ===
    use sui::coin::{Self, TreasuryCap};
    use sui::clock::{Clock};

    // === Errors ===
    /// Error code for minting more tokens than allowed
    const EMintLimitReached: u64 = 0;
    /// Error code for invalid schedule entry
    const EInvalidScheduleEntry: u64 = 1;

    // === Structs ===
    /// The schedule's admin capability that allows to modify the schedule.
    public struct ScheduleAdminCap has key, store {
        /// The unique identifier of the schedule admin cap.
        id: UID,
    }

    /// The schedule entry.
    public struct ScheduleEntry<phantom T> has store, drop {
        /// The start time of the first epoch in milliseconds.
        start_time_ms: std::option::Option<u64>,
        /// The number of epochs to mint.
        number_of_epochs: u64,
        /// The current minting epoch number.
        current_epoch: u64,
        /// The duration of each epoch in milliseconds.
        epoch_duration_ms: u64,
        /// The pool addresses
        pools: vector<address>,
        /// Amount of coins to mint in each epoch.
        amounts: vector<u64>,
    }

    /// The minting treasury
    public struct Treasury<phantom T> has key, store{
        /// The unique identifier of the treasury.
        id: UID,
        /// The schedule entries
        schedule: vector<ScheduleEntry<T>>,
        /// The treasury cap for minting coins.
        cap: TreasuryCap<T>,
        /// The current schedule entry
        current_entry: u64,
        /// The start time of the first mint in milliseconds.
        start_time_ms: std::option::Option<u64>,
    }

    // === Functions ===
    /// Creates a new treasury with minting schedule.
    public(package) fun create<T>(cap: TreasuryCap<T>, schedule: vector<ScheduleEntry<T>>, ctx: &mut TxContext): ScheduleAdminCap {
        transfer::public_share_object(Treasury {
            id: object::new(ctx),
            schedule: schedule,
            cap: cap,
            current_entry: 0,
            start_time_ms: option::none(),
        });
        ScheduleAdminCap {
            id: object::new(ctx),
        }
    }

    /// Creates a new schedule entry.
    public(package) fun create_entry<T>(
        start_time_ms: Option<u64>,
        number_of_epochs: u64,
        epoch_duration_ms: u64,
        pools: vector<address>,
        amounts: vector<u64>,
    ): ScheduleEntry<T> {
        assert!(pools.length() == amounts.length(), EInvalidScheduleEntry);
        assert!(number_of_epochs > 0, EInvalidScheduleEntry);
        assert!(epoch_duration_ms > 0, EInvalidScheduleEntry);
        ScheduleEntry {
            start_time_ms: start_time_ms,
            number_of_epochs: number_of_epochs,
            current_epoch: 0,
            epoch_duration_ms: epoch_duration_ms,
            pools: pools,
            amounts: amounts,
        }
    }

    /// Mint coins according to the schedule.
    public(package) fun mint<T>(treasury: &mut Treasury<T>, _clock: &Clock, ctx: &mut TxContext) {
        assert!(treasury.schedule.length() > 0, EMintLimitReached);
        assert!(treasury.current_entry < treasury.schedule.length(), EMintLimitReached);
        let entry = treasury.schedule.borrow_mut(treasury.current_entry);
        let mut k = 0;
        while (k < entry.pools.length()) {
            let pool = entry.pools[k];
            let amount = entry.amounts[k];
            coin::mint_and_transfer(&mut treasury.cap, amount, pool, ctx);
            k = k + 1;
        };
        entry.current_epoch = entry.current_epoch + 1;
        if (entry.current_epoch == entry.number_of_epochs) {
            treasury.current_entry = treasury.current_entry + 1;
        }
    }
}

#[test_only]
module blhnsuicntrtctkn::treasury_tests {
    use blhnsuicntrtctkn::treasury::{Self, Treasury, ScheduleEntry, EInvalidScheduleEntry, EMintLimitReached};
    use sui::clock::{Self, Clock};
    use sui::coin::{Self};
    use sui::test_scenario::{Self, Scenario};
    use sui::test_utils;

    const PUBLISHER: address = @0xA;
    const TEST_POOL1: address = @0xBBB;
    const TEST_POOL2: address = @0xCCC;

    public struct TREASURY_TESTS has drop {}

    #[test]
    #[expected_failure(abort_code = EInvalidScheduleEntry)]
    fun test_create_entry_with_invalid_targets() {
        // The number of elements in pools does not match the number of elements in amounts.
        treasury::create_entry<TREASURY_TESTS>(option::none(), 10, 3600, vector[@0xBBB], vector[]);
    }

    #[test]
    #[expected_failure(abort_code = EInvalidScheduleEntry)]
    fun test_create_entry_with_invalid_number_of_epochs() {
        // The number of epochs is zero.
        treasury::create_entry<TREASURY_TESTS>(option::none(), 0, 3600, vector[@0xBBB], vector[100]);
    }

    #[test]
    #[expected_failure(abort_code = EInvalidScheduleEntry)]
    fun test_create_entry_with_invalid_epoch_duration() {
        // The epoch duration is zero.
        treasury::create_entry<TREASURY_TESTS>(option::none(), 10, 0, vector[@0xBBB], vector[100]);
    }

    #[test]
    fun test_create_entry_returns_valid_entry() {
        // Do not errors because the entry is valid.
        treasury::create_entry<TREASURY_TESTS>(option::none(), 10, 3600, vector[@0xBBB], vector[100]);
    }

    #[test]
    #[expected_failure(abort_code = EMintLimitReached)]
    fun test_mint_errors_on_empty_schedule() {
        let mut scenario = setup_scenario(vector[]);
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            let mut treasury = test_scenario::take_shared<Treasury<TREASURY_TESTS>>(&scenario); 
            let clock = test_scenario::take_shared<Clock>(&scenario);
            treasury::mint(&mut treasury, &clock, scenario.ctx());
            test_scenario::return_shared<Treasury<TREASURY_TESTS>>(treasury);
            test_scenario::return_shared<Clock>(clock);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_mint_creates_and_transfers_coins_to_targets_specified_in_schedule() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(option::none(), 1, 3600, vector[TEST_POOL1, TEST_POOL2], vector[100, 200]),
        ]);
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            let mut treasury = test_scenario::take_shared<Treasury<TREASURY_TESTS>>(&scenario); 
            let clock = test_scenario::take_shared<Clock>(&scenario);
            treasury::mint(&mut treasury, &clock, scenario.ctx());
            test_scenario::return_shared<Treasury<TREASURY_TESTS>>(treasury);
            test_scenario::return_shared<Clock>(clock);
        };
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            assert_eq_chirp_coin(TEST_POOL1, 100, &scenario);
            assert_eq_chirp_coin(TEST_POOL2, 200, &scenario);
        };
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = EMintLimitReached)]
    fun test_mint_creates_and_transfers_coins_until_end_of_schedule(){
        let mut scenario = setup_scenario(vector[
            // The schedule contains a single entry with two epochs, each lasting 1000ms
            treasury::create_entry(option::none(), 2, 1000, vector[TEST_POOL1], vector[100]),
        ]);
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            let mut treasury = test_scenario::take_shared<Treasury<TREASURY_TESTS>>(&scenario); 
            let mut clock = test_scenario::take_shared<Clock>(&scenario);

            // The minting for the first epoch should succeed.
            treasury::mint(&mut treasury, &clock, scenario.ctx());
            clock::increment_for_testing(&mut clock, 1000);
            // The minting for the second epoch should succeed.
            treasury::mint(&mut treasury, &clock, scenario.ctx());

            test_scenario::return_shared<Treasury<TREASURY_TESTS>>(treasury);
            test_scenario::return_shared<Clock>(clock);
        };
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            assert_eq_chirp_coin(TEST_POOL1, 200, &scenario);
        };
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            let mut treasury = test_scenario::take_shared<Treasury<TREASURY_TESTS>>(&scenario); 
            let clock = test_scenario::take_shared<Clock>(&scenario);

            // The minting should fail because the schedule has ended.
            treasury::mint(&mut treasury, &clock, scenario.ctx());

            test_scenario::return_shared<Treasury<TREASURY_TESTS>>(treasury);
            test_scenario::return_shared<Clock>(clock);
        };
        test_scenario::end(scenario);
    }

    /// Sets up a scenario with the given minting schedule.
    fun setup_scenario(schedule: vector<ScheduleEntry<TREASURY_TESTS>>): Scenario {
        let mut scenario = test_scenario::begin(PUBLISHER);
        {
            let otw = test_utils::create_one_time_witness<TREASURY_TESTS>();
            let (cap, metadata) = coin::create_currency(otw, 10, b"TST", b"Test Token", b"Test Token", option::none(), scenario.ctx());
            transfer::public_freeze_object(metadata);
            transfer::public_transfer(treasury::create(cap, schedule, scenario.ctx()), PUBLISHER);
            clock::share_for_testing(clock::create_for_testing(scenario.ctx()));
        };
        scenario
    }

    /// Asserts that the value of the CHIRP coin held by the owner is equal to the expected value.
    fun assert_eq_chirp_coin(owner: address, expected_value: u64, scenario: &test_scenario::Scenario) {
        test_utils::assert_eq(total_coins(owner, scenario), expected_value);
    }

    /// Returns the total value of the test coins held by the owner.
    fun total_coins(owner: address, scenario: &test_scenario::Scenario): u64 {
        let coin_ids = test_scenario::ids_for_address<coin::Coin<TREASURY_TESTS>>(owner);
        let mut i = 0;
        let mut total = 0;
        while (i < coin_ids.length()) {
            let coin = test_scenario::take_from_address_by_id<coin::Coin<TREASURY_TESTS>>(scenario, owner, coin_ids[i]);
            total = total + coin::value(&coin);
            test_scenario::return_to_address<coin::Coin<TREASURY_TESTS>>(owner, coin);
            i = i + 1;
        };
        total
    }
}
