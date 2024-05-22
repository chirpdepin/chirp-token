/// Module for managing the CHIRP token and its minting schedule on the Sui
/// blockchain.
///
/// This module facilitates the creation, minting, and schedule management of
/// CHIRP tokens. It supports minting according to a predefined on-chain
/// schedule accessible to any user or contract, while ensuring adherence to
/// the specified timing constraints. Additionally, the module includes
/// administrative functions that empower a designated authority with the
/// ScheduleAdminCap capability to adapt the minting schedule under exceptional
/// circumstances.
module blhnsuicntrtctkn::chirp {
    // === Imports ===
    use blhnsuicntrtctkn::schedule::{Self};
    use blhnsuicntrtctkn::treasury::{Self, Treasury};
    use blhnsuicntrtctkn::pool_dispatcher::{Self, PoolDispatcher};
    use sui::object_bag::{Self, ObjectBag};
    use sui::clock::{Clock};
    use sui::coin::{Self};
    use sui::url;

    // === Errors ===
    #[allow(unused_const)]
    /// Error code indicating that a migration attempt is not considered an
    /// upgrade.
    const ENotUpgrade: u64 = 1;
    /// Error code used when a function call is made from an incompatible
    /// package version.
    const EWrongVersion: u64 = 2;

    /// Error code used when an invalid pool is used in the schedule.
    const EInvalidPool: u64 = 3;

    // === Constants ===
    /// Maximum supply of CHIRP tokens.
    const COIN_MAX_SUPPLY: u64 = 3_000_000_000_000_000_000;
    /// Number of decimal places for CHIRP coins, where 10 implies
    /// 10,000,000,000 smallest units (cents) per CHIRP token.
    const COIN_DECIMALS: u8 = 10;
    /// Human-readable description of the CHIRP token.
    const COIN_DESCRIPTION: vector<u8> = b"Chirp token description";
    /// Official name of the CHIRP token.
    const COIN_NAME: vector<u8> = b"Chirp Token";
    /// Symbol for the CHIRP token, aligned with ISO 4217 formatting.
    const COIN_SYMBOL: vector<u8> = b"CHIRP";
    /// Coin icon
    const COIN_ICON: vector<u8> = b"https://storage.googleapis.com/chirp-blhn-assets/images/CHIRP_White_OBG.svg";
    /// Current version of the vault.
    const VAULT_VERSION: u64 = 1;

    // === Structs ===
    /// The one-time witness for the module
    public struct CHIRP has drop {}

    /// Administrative capability for modifying the minting schedule.
    ///
    /// This struct acts as an authorization object, enabling its holder to
    /// perform authorized actions such as modifying the minting schedule. It
    /// ensures that schedule modifications are restricted to authorized
    /// personnel only.
    public struct ScheduleAdminCap has key, store {
        /// Unique identifier for the administrative capability.
        id: UID,
    }

    /// The central registry for all contract components.
    public struct Vault has key, store {
        /// The unique identifier of the vault.
        id: UID,
        /// The registry of all contract components.
        registry: ObjectBag,
        /// Version of the vault.
        version: u64,
    }

    // === Functions ===
    /// Initialize the CHIRP token on the blockchain and set up the minting
    /// schedule.
    ///
    /// This function creates a new CHIRP token, defines its properties such
    /// as number of decimals places, symbol, name, and description, and
    /// establishes a treasury for it. It also assigns an admin capability to
    /// the sender of the transaction that allows them to manage the minting
    /// schedule.
    fun init(otw: CHIRP, ctx: &mut TxContext) {
        let (treasury_cap, metadata) = coin::create_currency(
            otw,
            COIN_DECIMALS,
            COIN_SYMBOL,
            COIN_NAME,
            COIN_DESCRIPTION,
            option::some(url::new_unsafe_from_bytes(COIN_ICON)),
            ctx,
        );
        transfer::public_freeze_object(metadata);

        let mut vault = Vault {
            id: object::new(ctx),
            registry: object_bag::new(ctx),
            version: VAULT_VERSION,
        };

        vault.registry.add(b"pool_dispatcher", pool_dispatcher::default(ctx));
        vault.registry.add(b"treasury", treasury::create(treasury_cap, COIN_MAX_SUPPLY, schedule::default(), ctx));
        transfer::transfer(ScheduleAdminCap{id:object::new(ctx)}, ctx.sender());

        transfer::share_object(vault);
    }

    /// Mints new CHIRP tokens according to the predefined schedule.
    ///
    /// This function allows any user to mint CHIRP tokens in accordance with the
    /// established minting schedule. No special capabilities are required to invoke
    /// this function. It can be called anytime after the designated time in the schedule,
    /// except for the "zero mint," which can occur at any time after contract deployment.
    ///
    /// ## Parameters:
    /// - `vault`: Mutable reference to the Vault managing the minting process.
    /// - `clock`: Reference to the Clock, providing the current time context.
    ///
    /// ## Errors
    /// - `EWrongVersion`: If the treasury version does not match the VAULT_VERSION.
    /// - `EMintLimitReached`: If the minting has reached its limit or if the schedule is not set.
    /// - `EInappropriateTimeToMint`: If the mint attempt occurs outside the allowable schedule window.
    public fun mint(vault: &mut Vault, clock: &Clock, ctx: &mut TxContext) {
        assert!(vault.version == VAULT_VERSION, EWrongVersion);
        let (mut pools, mut coins) = {
            let treasury: &mut Treasury<CHIRP> = &mut vault.registry[b"treasury"]; 
            treasury.mint(clock, ctx)
        };
        {
            let dispatcher: &PoolDispatcher = &vault.registry[b"pool_dispatcher"];
            while(!pools.is_empty()) {
                let pool = pools.pop_back();
                let coin = coins.pop_back();
                dispatcher.transfer(pool, coin);
            };
            pools.destroy_empty();
            coins.destroy_empty();
        }

    }

    /// Replaces a schedule entry in the `Vault` of CHIRP tokens.
    ///
    /// This function updates the currently active schedule entry or subsequent
    /// entries. If the contract has been deployed and no minting has occurred,
    /// it permits replacement of any entry.
    ///
    /// ## Parameters:
    /// - `_`: Reference to the ScheduleAdminCap, ensuring execution by authorized users only.
    /// - `vault`: Mutable reference to the Vault managing the minting schedule.
    /// - `index`: Index of the schedule entry to update.
    /// - `pools`: Vector of addresses for the distribution pools.
    /// - `amounts`: Vector of amounts corresponding to each address in the pools.
    /// - `number_of_epochs`: Number of CHIRP epochs the entry will remain active.
    /// - `epoch_duration_ms`: Duration of each epoch in milliseconds.
    /// - `timeshift_ms`: Initial time shift for the entry start in milliseconds.
    ///
    /// ## Errors
    /// - `EWrongVersion`: If the treasury version does not match the VAULT_VERSION.
    /// - `EIndexOutOfRange`: If specified index is out of range or entry is irreplaceable.
    /// - `EInvalidScheduleEntry`: If the parameters of the new entry are invalid.
    /// - `EInvalidPool`: If the pools specified in the entry are not valid.
    public fun set_entry(
        _: &ScheduleAdminCap,
        vault: &mut Vault,
        index: u64,
        pools: vector<vector<u8>>,
        amounts: vector<u64>,
        number_of_epochs: u64,
        epoch_duration_ms: u64,
        timeshift_ms: u64,
    ) {
        assert!(vault.version == VAULT_VERSION, EWrongVersion);
        {
            let dispatcher: &PoolDispatcher = &vault.registry[b"pool_dispatcher"];
            let mut i = 0;
            while(i < pools.length()) {
                assert!(dispatcher.contains(pools[i]), EInvalidPool);
                i = i + 1;
            };
        };
        let entry = treasury::create_entry<CHIRP>(pools, amounts, number_of_epochs, epoch_duration_ms, timeshift_ms);
        let treasury: &mut Treasury<CHIRP> = &mut vault.registry[b"treasury"]; 
        treasury.set_entry(index, entry)
    }

    /// Inserts a new schedule entry before the specified index in the `Vault` of CHIRP tokens.
    ///
    /// Authorized users with the ScheduleAdminCap can insert a new entry at
    /// any position following the current active entry. If no minting has
    /// occurred since the contract's deployment, entries can be inserted at
    /// any position.
    ///
    /// ## Parameters:
    /// - `_`: Reference to the ScheduleAdminCap, ensuring execution by authorized users only.
    /// - `vault`: Mutable reference to the Vault managing the minting schedule.
    /// - `index`: The position at which the new entry will be inserted.
    /// - `pools`: Vector of addresses for the distribution pools.
    /// - `amounts`: Vector of amounts corresponding to each address in the pools.
    /// - `number_of_epochs`: Number of CHIRP epochs the entry will be active.
    /// - `epoch_duration_ms`: Duration of each epoch in milliseconds.
    /// - `timeshift_ms`: Initial time shift for the entry start in milliseconds.
    ///
    /// ## Errors
    /// - `EWrongVersion`: If the treasury version does not match the VAULT_VERSION.
    /// - `EIndexOutOfRange`: If the specified index is out of range for insertion.
    /// - `EInvalidScheduleEntry`: If the parameters of the new entry are invalid.
    /// - `EInvalidPool`: If the pools specified in the entry are not valid.
    public fun insert_entry(
        _: &ScheduleAdminCap,
        vault: &mut Vault,
        index: u64,
        pools: vector<vector<u8>>,
        amounts: vector<u64>,
        number_of_epochs: u64,
        epoch_duration_ms: u64,
        timeshift_ms: u64,
    ) {
        assert!(vault.version == VAULT_VERSION, EWrongVersion);
        {
            let dispatcher: &PoolDispatcher = &vault.registry[b"pool_dispatcher"];
            let mut i = 0;
            while(i < pools.length()) {
                assert!(dispatcher.contains(pools[i]), EInvalidPool);
                i = i + 1;
            };
        };
        let entry = treasury::create_entry<CHIRP>(pools, amounts, number_of_epochs, epoch_duration_ms, timeshift_ms);
        let treasury: &mut Treasury<CHIRP> = &mut vault.registry[b"treasury"]; 
        treasury.insert_entry(index, entry)
    }

    /// Removes a schedule entry at the specified index in the `Vault` of CHIRP tokens.
    ///
    /// This function allows authorized users, holding the ScheduleAdminCap, to
    /// remove an existing entry from the minting schedule. The function can
    /// only modify entries that follow the currently active entry unless no
    /// minting has occurred since the contract's deployment, in which case any
    /// entry can be removed.
    ///
    /// ## Parameters:
    /// - `_`: Reference to the ScheduleAdminCap, ensuring execution by authorized users only.
    /// - `vault`: Mutable reference to the Vault managing the minting schedule.
    /// - `index`: The position from which the entry will be removed.
    ///
    /// ## Errors
    /// - `EWrongVersion`: If the treasury version does not match the VAULT_VERSION.
    /// - `EIndexOutOfRange`: If the specified index is out of range for removal.
    public fun remove_entry(_: &ScheduleAdminCap, vault: &mut Vault, index: u64) {
        assert!(vault.version == VAULT_VERSION, EWrongVersion);
        let treasury: &mut Treasury<CHIRP> = &mut vault.registry[b"treasury"]; 
        treasury.remove_entry(index);
    }

    /// Sets the address of the pool in schedule.
    ///
    /// This function allows authorized users, holding the ScheduleAdminCap, to
    /// set the address of the pool in the schedule.
    ///
    /// ## Parameters:
    /// - `_`: Reference to the ScheduleAdminCap, ensuring execution by authorized users only.
    /// - `vault`: Mutable reference to the Vault managing the minting schedule.
    /// - `name`: The name of the pool.
    /// - `pool`: The address of the pool.
    ///
    /// ## Errors
    /// - `EWrongVersion`: If the treasury version does not match the VAULT_VERSION.
    /// - `EInvalidPool`: If the pool is not valid.
    public fun set_address_pool(_: &ScheduleAdminCap, vault: &mut Vault, name: vector<u8>, pool: address) {
        assert!(vault.version == VAULT_VERSION, EWrongVersion);
        let dispatcher: &mut PoolDispatcher = &mut vault.registry[b"pool_dispatcher"];
        assert!(dispatcher.contains(name), EInvalidPool);
        dispatcher.set_address_pool(name, pool);
    }

    #[test_only]
    public fun init_for_testing(ctx: &mut TxContext) {
        init(CHIRP{}, ctx)
    }

    #[test_only]
    public fun add_address_pool(vault: &mut Vault, name: vector<u8>, pool: address) {
        let dispatcher: &mut PoolDispatcher = &mut vault.registry[b"pool_dispatcher"];
        dispatcher.add_address_pool(name, pool);
    }

    #[test_only]
    public fun get_address_pool(vault: &Vault, name: vector<u8>): address {
        let dispatcher: &PoolDispatcher = &vault.registry[b"pool_dispatcher"];
        dispatcher.get_address_pool(name)
    }

    #[test_only] public fun coin_decimals(): u8 { COIN_DECIMALS }
    #[test_only] public fun coin_description(): vector<u8> { COIN_DESCRIPTION }
    #[test_only] public fun coin_name(): vector<u8> { COIN_NAME }
    #[test_only] public fun coin_symbol(): vector<u8> { COIN_SYMBOL }
}

#[test_only]
module blhnsuicntrtctkn::chirp_tests {
    use blhnsuicntrtctkn::chirp::{Self, CHIRP, EInvalidPool, ScheduleAdminCap, Vault};
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
            let mut vault: Vault = scenario.take_shared();
            vault.add_address_pool(b"test_pool", PUBLISHER);
            test_scenario::return_shared(vault);
        };
        scenario.next_tx(PUBLISHER);
        {
            let mut vault: Vault = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            let cap: ScheduleAdminCap = test_scenario::take_from_sender(&scenario);

            // Setting zero mint params
            chirp::set_entry(&cap, &mut vault, 0, vector[b"test_pool"], vector[1000], 1, 1000, 0);
            chirp::mint(&mut vault, &clock, scenario.ctx());

            test_scenario::return_shared(vault);
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
    #[expected_failure(abort_code = EInvalidPool)]
    fun test_set_entry_disallows_to_specify_non_existent_pools()
    {
        let mut scenario = test_scenario::begin(PUBLISHER);
        {
            chirp::init_for_testing(scenario.ctx());
            clock::share_for_testing(clock::create_for_testing(scenario.ctx()));
        };
        scenario.next_tx(PUBLISHER);
        {
            let mut vault: Vault = scenario.take_shared();
            let cap: ScheduleAdminCap = test_scenario::take_from_sender(&scenario);

            // Fails because the pool does not exist
            chirp::set_entry(&cap, &mut vault, 0, vector[b"non_existent_pool"], vector[1000], 1, 1000, 0);

            test_scenario::return_shared(vault);
            test_scenario::return_to_sender(&scenario, cap);
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
            let mut vault: Vault = scenario.take_shared();
            vault.add_address_pool(b"test_pool", PUBLISHER);
            test_scenario::return_shared(vault);
        };
        scenario.next_tx(PUBLISHER);
        {
            let mut vault: Vault = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            let cap: ScheduleAdminCap = test_scenario::take_from_sender(&scenario);

            // inserting new zero mint stage
            chirp::insert_entry(&cap, &mut vault, 0, vector[b"test_pool"], vector[1000], 1, 1000, 0);
            chirp::mint(&mut vault, &clock, scenario.ctx());

            test_scenario::return_shared(vault);
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
    #[expected_failure(abort_code = EInvalidPool)]
    fun test_insert_entry_disallows_to_specify_non_existent_pools()
    {
        let mut scenario = test_scenario::begin(PUBLISHER);
        {
            chirp::init_for_testing(scenario.ctx());
            clock::share_for_testing(clock::create_for_testing(scenario.ctx()));
        };
        scenario.next_tx(PUBLISHER);
        {
            let mut vault: Vault = scenario.take_shared();
            let cap: ScheduleAdminCap = test_scenario::take_from_sender(&scenario);
            // Fails because the pool does not exist
            chirp::insert_entry(&cap, &mut vault, 0, vector[b"non_existent_pool"], vector[1000], 1, 1000, 0);
            test_scenario::return_shared(vault);
            test_scenario::return_to_sender(&scenario, cap);
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
            let mut vault: Vault = scenario.take_shared();
            vault.add_address_pool(b"test_pool", PUBLISHER);
            test_scenario::return_shared(vault);
        };
        scenario.next_tx(PUBLISHER);
        {
            let mut vault: Vault = scenario.take_shared();
            let clock: Clock = scenario.take_shared();
            let cap: ScheduleAdminCap = test_scenario::take_from_sender(&scenario);

            chirp::insert_entry(&cap, &mut vault, 0, vector[b"test_pool"], vector[1000], 1, 1000, 0);
            chirp::insert_entry(&cap, &mut vault, 1, vector[b"test_pool"], vector[3117], 1, 1000, 0);
            // removing first mint stage
            chirp::remove_entry(&cap, &mut vault, 0);

            // Should mint 3117 coins
            chirp::mint(&mut vault, &clock, scenario.ctx());

            test_scenario::return_shared(vault);
            test_scenario::return_shared(clock);
            test_scenario::return_to_sender(&scenario, cap);
        };
        scenario.next_tx(PUBLISHER);
        {
            assert_eq_chirp_coin(PUBLISHER, 3117, &scenario);
        };
        scenario.end();
    }

    #[test]
    #[expected_failure(abort_code = EInvalidPool)]
    fun test_set_address_pool_disallows_to_set_non_existent_pool()
    {
        let mut scenario = test_scenario::begin(PUBLISHER);
        {
            chirp::init_for_testing(scenario.ctx());
        };
        scenario.next_tx(PUBLISHER);
        {
            let mut vault: Vault = scenario.take_shared();
            let cap: ScheduleAdminCap = test_scenario::take_from_sender(&scenario);
            // Fails because the pool does not exist
            chirp::set_address_pool(&cap, &mut vault, b"non_existent_pool", PUBLISHER);
            test_scenario::return_shared(vault);
            test_scenario::return_to_sender(&scenario, cap);
        };
        scenario.end();
    }

    #[test]
    fun test_set_address_pool_allows_to_set_address_of_pool()
    {
        let mut scenario = test_scenario::begin(PUBLISHER);
        {
            chirp::init_for_testing(scenario.ctx());
        };
        scenario.next_tx(PUBLISHER);
        {
            let mut vault: Vault = scenario.take_shared();
            vault.add_address_pool(b"test_pool", @0xDEADBEEF);
            test_scenario::return_shared(vault);
        };
        scenario.next_tx(PUBLISHER);
        {
            let mut vault: Vault = scenario.take_shared();
            let cap: ScheduleAdminCap = test_scenario::take_from_sender(&scenario);
            chirp::set_address_pool(&cap, &mut vault, b"test_pool", PUBLISHER);
            test_scenario::return_shared(vault);
            test_scenario::return_to_sender(&scenario, cap);
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
