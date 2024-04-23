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
    /// Error code for inpropriate time to mint
    const EInappropriateTimeToMint: u64 = 2;

    // === Structs ===
    /// The schedule's admin capability that allows to modify the schedule.
    public struct ScheduleAdminCap has key, store {
        /// The unique identifier of the schedule admin cap.
        id: UID,
    }

    /// The schedule entry.
    public struct ScheduleEntry<phantom T> has store, drop {
        /// The time shift relative to the end of the preceding entry or
        /// initial minting time.
        timeshift_ms: std::option::Option<u64>,
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
    }

    // === Public package functions ===
    /// Creates a new treasury with minting schedule.
    public(package) fun create<T>(cap: TreasuryCap<T>, schedule: vector<ScheduleEntry<T>>, ctx: &mut TxContext): ScheduleAdminCap {
        transfer::public_share_object(Treasury {
            id: object::new(ctx),
            schedule: schedule,
            cap: cap,
            current_entry: 0,
        });
        ScheduleAdminCap {
            id: object::new(ctx),
        }
    }

    /// Creates a new schedule entry.
    public(package) fun create_entry<T>(
        pools: vector<address>,
        amounts: vector<u64>,
        number_of_epochs: u64,
        epoch_duration_ms: u64,
        timeshift_ms: Option<u64>,
    ): ScheduleEntry<T> {
        assert!(pools.length() == amounts.length(), EInvalidScheduleEntry);
        assert!(number_of_epochs > 0, EInvalidScheduleEntry);
        assert!(epoch_duration_ms > 0, EInvalidScheduleEntry);
        ScheduleEntry {
            timeshift_ms: timeshift_ms,
            number_of_epochs: number_of_epochs,
            current_epoch: 0,
            epoch_duration_ms: epoch_duration_ms,
            pools: pools,
            amounts: amounts,
        }
    }

    /// Mint coins according to the schedule.
    public(package) fun mint<T>(treasury: &mut Treasury<T>, clock: &Clock, ctx: &mut TxContext) {
        assert!(treasury.schedule.length() > 0, EMintLimitReached);
        assert!(treasury.current_entry < treasury.schedule.length(), EMintLimitReached);
        let next_stage_ms = mint_entry(&mut treasury.schedule[treasury.current_entry], &mut treasury.cap, clock, ctx);
        if (next_stage_ms.is_some()) {
            treasury.current_entry = treasury.current_entry + 1;
            if (treasury.current_entry < treasury.schedule.length()) {
                let next_entry = &mut treasury.schedule[treasury.current_entry];
                next_entry.timeshift_ms = option::some(next_stage_ms.get_with_default(0) + next_entry.timeshift_ms.get_with_default(0));
            }
        }
    }

    // === Internal functions ===

    /// Mint coins following the specified parameters and return the time for the next stage after all epochs are minted.
    fun mint_entry<T>(entry: &mut ScheduleEntry<T>, cap: &mut TreasuryCap<T>, clock: &Clock, ctx: &mut TxContext): Option<u64> {
        if (entry.timeshift_ms.is_none()) {
            entry.timeshift_ms = option::some(clock.timestamp_ms());
        };
        assert!(clock.timestamp_ms() >= entry.timeshift_ms.get_with_default(0) + entry.current_epoch * entry.epoch_duration_ms, EInappropriateTimeToMint);
        let mut k = 0;
        while (k < entry.pools.length()) {
            let pool = entry.pools[k];
            let amount = entry.amounts[k];
            coin::mint_and_transfer(cap, amount, pool, ctx);
            k = k + 1;
        };
        entry.current_epoch = entry.current_epoch + 1;
        if (entry.current_epoch == entry.number_of_epochs) {
            return option::some(entry.timeshift_ms.get_with_default(0) + entry.number_of_epochs * entry.epoch_duration_ms)
        };
        return option::none()
    }
}

#[test_only]
module blhnsuicntrtctkn::treasury_tests {
    use blhnsuicntrtctkn::treasury::{Self, Treasury, ScheduleEntry, EInvalidScheduleEntry, EMintLimitReached, EInappropriateTimeToMint};
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
        treasury::create_entry<TREASURY_TESTS>(vector[@0xBBB], vector[], 10, 3600, option::none());
    }

    #[test]
    #[expected_failure(abort_code = EInvalidScheduleEntry)]
    fun test_create_entry_with_invalid_number_of_epochs() {
        // The number of epochs is zero.
        treasury::create_entry<TREASURY_TESTS>(vector[@0xBBB], vector[100], 0, 3600, option::none());
    }

    #[test]
    #[expected_failure(abort_code = EInvalidScheduleEntry)]
    fun test_create_entry_with_invalid_epoch_duration() {
        // The epoch duration is zero.
        treasury::create_entry<TREASURY_TESTS>(vector[@0xBBB], vector[100], 10, 0, option::none());
    }

    #[test]
    fun test_create_entry_returns_valid_entry() {
        // Do not errors because the entry is valid.
        treasury::create_entry<TREASURY_TESTS>(vector[@0xBBB], vector[100], 10, 3600, option::none());
    }

    #[test]
    #[expected_failure(abort_code = EMintLimitReached)]
    fun test_mint_errors_on_empty_schedule() {
        let mut scenario = setup_scenario(vector[]);
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            let mut treasury = test_scenario::take_shared<Treasury<TREASURY_TESTS>>(&scenario);
            let clock = test_scenario::take_shared<Clock>(&scenario);
            treasury.mint(&clock, scenario.ctx());
            test_scenario::return_shared<Treasury<TREASURY_TESTS>>(treasury);
            test_scenario::return_shared<Clock>(clock);
        };
        test_scenario::end(scenario);
    }

    #[test]
    fun test_mint_creates_and_transfers_coins_to_targets_specified_in_schedule() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1, TEST_POOL2], vector[100, 200], 1, 3600, option::none()),
        ]);
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            let mut treasury = test_scenario::take_shared<Treasury<TREASURY_TESTS>>(&scenario);
            let clock = test_scenario::take_shared<Clock>(&scenario);
            treasury.mint(&clock, scenario.ctx());
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
    #[expected_failure(abort_code = EInappropriateTimeToMint)]
    fun test_mint_fails_when_minting_time_has_not_come_yet() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 2, 1000, option::none()),
        ]);
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            let mut treasury = test_scenario::take_shared<Treasury<TREASURY_TESTS>>(&scenario);
            let clock = test_scenario::take_shared<Clock>(&scenario);

            treasury.mint(&clock, scenario.ctx());
            // The minting should fail because the minting time has not come yet.
            treasury.mint(&clock, scenario.ctx());

            test_scenario::return_shared<Treasury<TREASURY_TESTS>>(treasury);
            test_scenario::return_shared<Clock>(clock);
        };
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = EMintLimitReached)]
    fun test_mint_creates_and_transfers_coins_until_end_of_schedule(){
        let mut scenario = setup_scenario(vector[
            // The schedule contains a single entry with two epochs, each lasting 1000ms
            treasury::create_entry(vector[TEST_POOL1], vector[100], 2, 1000, option::none()),
        ]);
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            let mut treasury = test_scenario::take_shared<Treasury<TREASURY_TESTS>>(&scenario);
            let mut clock = test_scenario::take_shared<Clock>(&scenario);

            // The minting for the first epoch should succeed.
            treasury.mint(&clock, scenario.ctx());
            clock.increment_for_testing(1000);
            // The minting for the second epoch should succeed.
            treasury.mint(&clock, scenario.ctx());

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
            treasury.mint(&clock, scenario.ctx());

            test_scenario::return_shared<Treasury<TREASURY_TESTS>>(treasury);
            test_scenario::return_shared<Clock>(clock);
        };
        test_scenario::end(scenario);
    }

    #[test]
    // The next stage must be initiated after the minting stage is complete
    fun test_mint_starts_then_next_stage() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 1000, option::none()),
            treasury::create_entry(vector[TEST_POOL2], vector[200], 1, 1000, option::none()),
        ]);
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            let mut treasury = test_scenario::take_shared<Treasury<TREASURY_TESTS>>(&scenario);
            let mut clock = test_scenario::take_shared<Clock>(&scenario);
            // The minting for the first epoch of first stage should succeed.
            treasury.mint(&clock, scenario.ctx());

            clock.increment_for_testing(1000);

            // The minting for the first epoch of the second stage should succeed.
            treasury.mint(&clock, scenario.ctx());
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
    #[expected_failure(abort_code = EInappropriateTimeToMint)]
    // The next stage starts after duration of previous stage
    fun test_mint_fails_when_minting_time_has_not_come_yet_for_next_stage() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 1000, option::none()),
            treasury::create_entry(vector[TEST_POOL2], vector[200], 1, 1000, option::none()),
        ]);
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            let mut treasury = test_scenario::take_shared<Treasury<TREASURY_TESTS>>(&scenario);
            let clock = test_scenario::take_shared<Clock>(&scenario);
            treasury.mint(&clock, scenario.ctx());
            // Minting must not succeed until at least 1000 ms have passed since the last epoch of the initial stage.
            treasury.mint(&clock, scenario.ctx());
            test_scenario::return_shared<Treasury<TREASURY_TESTS>>(treasury);
            test_scenario::return_shared<Clock>(clock);
        };
        test_scenario::end(scenario);
    }

    #[test]
    #[expected_failure(abort_code = EInappropriateTimeToMint)]
    // The next stage might have the optional time shift
    fun test_mint_fails_when_minting_time_has_not_come_yet_for_next_stage_with_time_shift() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 1000, option::none()),
            // The second stage starts 2000 ms after the end of the first stage.
            treasury::create_entry(vector[TEST_POOL2], vector[200], 1, 1000, option::some(2000)),
        ]);
        test_scenario::next_tx(&mut scenario, PUBLISHER);
        {
            let mut treasury = test_scenario::take_shared<Treasury<TREASURY_TESTS>>(&scenario);
            let mut clock = test_scenario::take_shared<Clock>(&scenario);
            treasury.mint(&clock, scenario.ctx());

            clock.increment_for_testing(1000);

            // Minting must not succeed because the next stage has additional time shift.
            treasury.mint(&clock, scenario.ctx());
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
