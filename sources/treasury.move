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
    /// Error code for index out of range
    const EIndexOutOfRange: u64 = 3;

    // === Structs ===
    /// The schedule's admin capability that allows to modify the schedule.
    public struct ScheduleAdminCap has key, store {
        /// The unique identifier of the schedule admin cap.
        id: UID,
    }

    /// The stage of the minting schedule.
    public struct Stage<phantom T> has store, copy, drop {
        /// The time shift relative to the end of the preceding entry
        timeshift_ms: std::option::Option<u64>,
        /// The number of epochs to mint.
        number_of_epochs: u64,
        /// The duration of each epoch in milliseconds.
        epoch_duration_ms: u64,
        /// The pool addresses
        pools: vector<address>,
        /// Amount of coins to mint in each epoch.
        amounts: vector<u64>,
    }

    /// The schedule entry.
    public struct ScheduleEntry<phantom T> has store, drop {
        /// The start time of the entry in milliseconds.
        start_time_ms: std::option::Option<u64>,
        /// The current minting epoch number.
        current_epoch: u64,
        /// Stage parameters
        stage: Stage<T>,
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
        /// The version of the treasury
        version: u64,
    }

    // === Public package functions ===
    /// Creates a new treasury with minting schedule.
    public(package) fun create<T>(
        cap: TreasuryCap<T>,
        schedule: vector<ScheduleEntry<T>>,
        ctx: &mut TxContext,
    ): ScheduleAdminCap {
        transfer::share_object(Treasury {
            id: object::new(ctx),
            schedule: schedule,
            cap: cap,
            current_entry: 0,
            version: 1,
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
            stage: Stage {
                timeshift_ms: timeshift_ms,
                number_of_epochs: number_of_epochs,
                epoch_duration_ms: epoch_duration_ms,
                pools: pools,
                amounts: amounts,
            },
            start_time_ms: option::none(),
            current_epoch: 0,
        }
    }
    
    /// Replaces the schedule entry at the specified index with the new entry.
    public(package) fun set_entry<T>(
        treasury: &mut Treasury<T>,
        index: u64,
        entry: ScheduleEntry<T>,
    ) {
        assert!(index < treasury.schedule.length(), EIndexOutOfRange);
        assert!(index >= treasury.current_entry, EIndexOutOfRange);
        let target_entry = &mut treasury.schedule[index];
        if (treasury.current_entry == index) {
            assert!(entry.stage.number_of_epochs > target_entry.current_epoch, EInvalidScheduleEntry);
        };
        target_entry.stage = entry.stage;
    }

    /// Inserts the schedule entry at the specified index.
    public(package) fun insert_entry<T>(
        treasury: &mut Treasury<T>,
        index: u64,
        entry: ScheduleEntry<T>,
    ) {
        assert!(index <= treasury.schedule.length(), EIndexOutOfRange);
        assert!(treasury.current_entry == 0 || index > treasury.current_entry, EIndexOutOfRange);
        treasury.schedule.insert(entry, index);
    }

    /// Removes the schedule entry at the specified index.
    public(package) fun remove_entry<T>(treasury: &mut Treasury<T>, index: u64) {
        assert!(index < treasury.schedule.length(), EIndexOutOfRange);
        assert!(treasury.current_entry == 0 || index > treasury.current_entry, EIndexOutOfRange);
        treasury.schedule.remove(index);
    }

    /// Mint coins according to the schedule.
    public(package) fun mint<T>(treasury: &mut Treasury<T>, clock: &Clock, ctx: &mut TxContext) {
        assert!(treasury.schedule.length() > 0, EMintLimitReached);
        assert!(treasury.current_entry < treasury.schedule.length(), EMintLimitReached);
        let entry = &mut treasury.schedule[treasury.current_entry];
        let next_stage_ms = mint_entry(entry, &mut treasury.cap, clock, ctx);
        if (next_stage_ms.is_some()) {
            treasury.current_entry = treasury.current_entry + 1;
            if (treasury.current_entry < treasury.schedule.length()) {
                let next_entry = &mut treasury.schedule[treasury.current_entry];
                let next_start_time_ms = next_stage_ms.get_with_default(0);
                let next_timeshift_ms = next_entry.stage.timeshift_ms.get_with_default(0);
                next_entry.start_time_ms = option::some(next_start_time_ms + next_timeshift_ms);
            }
        }
    }

    /// Returns the treasury version.
    public(package) fun version<T>(treasury: &Treasury<T>): u64 {
        treasury.version
    }

    // === Internal functions ===

    /// Mint coins following the specified parameters and return the time for
    /// the next stage after all epochs are minted.
    fun mint_entry<T>(
        entry: &mut ScheduleEntry<T>,
        cap: &mut TreasuryCap<T>,
        clock: &Clock,
        ctx: &mut TxContext,
    ): Option<u64> {
        if (entry.start_time_ms.is_none()) {
            entry.start_time_ms = option::some(clock.timestamp_ms());
        };
        let mint_time = get_entry_mint_time(entry);
        assert!(clock.timestamp_ms() >= mint_time, EInappropriateTimeToMint);
        let mut k = 0;
        while (k < entry.stage.pools.length()) {
            let pool = entry.stage.pools[k];
            let amount = entry.stage.amounts[k];
            coin::mint_and_transfer(cap, amount, pool, ctx);
            k = k + 1;
        };
        entry.current_epoch = entry.current_epoch + 1;
        if (entry.current_epoch == entry.stage.number_of_epochs) {
            return option::some(get_entry_mint_time(entry))
        };
        return option::none()
   }

    /// Returns the mint time of the entry
    fun get_entry_mint_time<T>(entry: &ScheduleEntry<T>): u64 {
        let start_time = entry.start_time_ms.get_with_default(0);
        let time_shift = entry.stage.timeshift_ms.get_with_default(0);
        let time_elapsed_ms = entry.current_epoch * entry.stage.epoch_duration_ms;
        start_time + time_shift + time_elapsed_ms
    }
}

#[test_only]
module blhnsuicntrtctkn::treasury_tests {
    use blhnsuicntrtctkn::treasury::{
        ScheduleEntry,
        Self,
        Treasury, 
        EInappropriateTimeToMint,
        EIndexOutOfRange,
        EInvalidScheduleEntry,
        EMintLimitReached,
    };
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
    #[expected_failure(abort_code = EIndexOutOfRange)]
    fun test_set_entry_fails_for_invalid_index() {
        let mut scenario = setup_scenario(vector[]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            treasury.set_entry(0, treasury::create_entry(vector[@0xBBB], vector[100], 10, 3600, option::none()));
            test_scenario::return_shared(treasury);
        };
        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = EIndexOutOfRange)]
    fun test_set_entry_fails_for_already_minted_stages() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 3600, option::none()),
        ]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            treasury.mint(&clock, scenario.ctx());
            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            // Fails because the stage has already finished.
            treasury.set_entry(0, treasury::create_entry(vector[TEST_POOL1], vector[100], 10, 3600, option::none()));
            test_scenario::return_shared(treasury);
        };
        scenario.end();
    }

    #[test]
    fun test_set_entry_changes_the_stage_parameters() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 3600, option::none()),
        ]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            treasury.set_entry(0, treasury::create_entry(vector[TEST_POOL1], vector[1337], 1, 3600, option::none()));
            // Should mint 3117 coins
            treasury.mint(&clock, scenario.ctx());
            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.next_tx(PUBLISHER);
        {
            assert_eq_chirp_coin(TEST_POOL1, 1337, &scenario);
        };
        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = EInvalidScheduleEntry)]
    fun test_set_entry_fails_on_setting_number_of_epochs_less_or_equal_than_current_epoch() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 2, 3600, option::none()),
        ]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            treasury.mint(&clock, scenario.ctx());
            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            // Fails because the number of epochs is equal to the current epoch.
            treasury.set_entry(0, treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 3600, option::none()));
            test_scenario::return_shared(treasury);
        };
        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = EIndexOutOfRange)]
    fun test_insert_entry_fails_on_index_out_of_range() {
        let mut scenario = setup_scenario(vector[]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            // Fails because the index is out of range.
            treasury.insert_entry(1, treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 3600, option::none()));
            test_scenario::return_shared(treasury);
        };
        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = EIndexOutOfRange)]
    fun test_insert_entry_fails_on_already_minted_stages() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 3600, option::none()),
        ]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            treasury.mint(&clock, scenario.ctx());

            // Fails because the index is before current stage
            treasury.insert_entry(0, treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 3600, option::none()));

            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.end();
    }

    #[test]
    fun test_insert_entry_allows_to_insert_first_entry_if_the_schedule_was_not_started_yet() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 3600, option::none()),
        ]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            // Do not errors because the schedule was not started yet.
            treasury.insert_entry(0, treasury::create_entry(vector[TEST_POOL1], vector[200], 1, 3600, option::none()));
            treasury.mint(&clock, scenario.ctx());

            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.next_tx(PUBLISHER);
        {
            assert_eq_chirp_coin(TEST_POOL1, 200, &scenario);
        };
        scenario.end();
    }

    #[test]
    fun test_insert_entry_allows_to_insert_at_the_end_of_schedule() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 3600, option::none()),
        ]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();

            // Do not errors because the index is at the end of the schedule.
            treasury.insert_entry(1, treasury::create_entry(vector[TEST_POOL1], vector[200], 1, 3600, option::none()));
            treasury.mint(&clock, scenario.ctx());

            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.next_tx(PUBLISHER);
        {
            assert_eq_chirp_coin(TEST_POOL1, 100, &scenario);

            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let mut clock: Clock = scenario.take_shared();
            clock.increment_for_testing(3600);
            treasury.mint(&clock, scenario.ctx());
            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.next_tx(PUBLISHER);
        {
            // The total amount of coins should be 100+200=300
            assert_eq_chirp_coin(TEST_POOL1, 300, &scenario);
        };
        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = EIndexOutOfRange)]
    fun test_remove_entry_fails_on_index_out_of_range() {
        let mut scenario = setup_scenario(vector[]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            // Fails because the index is out of range.
            treasury.remove_entry(3117);
            test_scenario::return_shared(treasury);
        };
        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = EIndexOutOfRange)]
    fun test_remove_entry_fails_on_removing_past_or_current_entries() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 3600, option::none()),
        ]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            treasury.mint(&clock, scenario.ctx());
            // Fails because the stage was already minted
            treasury.remove_entry(0);

            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.end();
    }

    #[test]
    fun test_remove_entry_allows_to_remove_first_entry_if_the_schedule_was_not_started_yet() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 3600, option::none()),
            treasury::create_entry(vector[TEST_POOL2], vector[200], 1, 3600, option::none()),
        ]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            // Do not errors because the schedule was not started yet.
            treasury.remove_entry(0);
            test_scenario::return_shared(treasury);
        };
        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = EMintLimitReached)]
    fun test_mint_errors_on_empty_schedule() {
        let mut scenario = setup_scenario(vector[]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            treasury.mint(&clock, scenario.ctx());
            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.end();
    }

    #[test]
    fun test_mint_creates_and_transfers_coins_to_targets_specified_in_schedule() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1, TEST_POOL2], vector[100, 200], 1, 3600, option::none()),
        ]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            treasury.mint(&clock, scenario.ctx());
            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.next_tx(PUBLISHER);
        {
            assert_eq_chirp_coin(TEST_POOL1, 100, &scenario);
            assert_eq_chirp_coin(TEST_POOL2, 200, &scenario);
        };
        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = EInappropriateTimeToMint)]
    fun test_mint_fails_when_minting_time_has_not_come_yet() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 2, 1000, option::none()),
        ]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();

            treasury.mint(&clock, scenario.ctx());
            // The minting should fail because the minting time has not come yet.
            treasury.mint(&clock, scenario.ctx());

            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = EMintLimitReached)]
    fun test_mint_creates_and_transfers_coins_until_end_of_schedule(){
        let mut scenario = setup_scenario(vector[
            // The schedule contains a single entry with two epochs, each lasting 1000ms
            treasury::create_entry(vector[TEST_POOL1], vector[100], 2, 1000, option::none()),
        ]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let mut clock: Clock = scenario.take_shared();

            // The minting for the first epoch should succeed.
            treasury.mint(&clock, scenario.ctx());
            clock.increment_for_testing(1000);
            // The minting for the second epoch should succeed.
            treasury.mint(&clock, scenario.ctx());

            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.next_tx(PUBLISHER);
        {
            assert_eq_chirp_coin(TEST_POOL1, 200, &scenario);
        };
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();

            // The minting should fail because the schedule has ended.
            treasury.mint(&clock, scenario.ctx());

            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.end();
    }

    #[test]
    // The next stage must be initiated after the minting stage is complete
    fun test_mint_starts_then_next_stage() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 1000, option::none()),
            treasury::create_entry(vector[TEST_POOL2], vector[200], 1, 1000, option::none()),
        ]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let mut clock: Clock = scenario.take_shared();
            // The minting for the first epoch of first stage should succeed.
            treasury.mint(&clock, scenario.ctx());
            clock.increment_for_testing(1000);
            // The minting for the first epoch of the second stage should succeed.
            treasury.mint(&clock, scenario.ctx());
            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.next_tx(PUBLISHER);
        {
            assert_eq_chirp_coin(TEST_POOL1, 100, &scenario);
            assert_eq_chirp_coin(TEST_POOL2, 200, &scenario);
        };
        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = EInappropriateTimeToMint)]
    // The next stage starts after duration of previous stage
    fun test_mint_fails_when_minting_time_has_not_come_yet_for_next_stage() {
        let mut scenario = setup_scenario(vector[
            treasury::create_entry(vector[TEST_POOL1], vector[100], 1, 1000, option::none()),
            treasury::create_entry(vector[TEST_POOL2], vector[200], 1, 1000, option::none()),
        ]);
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            treasury.mint(&clock, scenario.ctx());
            // Minting must not succeed until at least 1000 ms have passed since the last epoch of the initial stage.
            treasury.mint(&clock, scenario.ctx());
            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.end();
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
        scenario.next_tx(PUBLISHER);
        {
            let mut treasury: Treasury<TREASURY_TESTS> = scenario.take_shared();
            let mut clock: Clock = scenario.take_shared();
            treasury.mint(&clock, scenario.ctx());
            clock.increment_for_testing(1000);
            // Minting must not succeed because the next stage has additional time shift.
            treasury.mint(&clock, scenario.ctx());
            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.end();
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
