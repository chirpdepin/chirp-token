/// This module implements the default minting schedule of CHIRP token
module blhnsuicntrtctkn::schedule {
    // === Imports ===
    use blhnsuicntrtctkn::treasury::{Self, ScheduleEntry};

    // === Constants ===
    const STRATEGIC_SUPPORTERS: vector<u8> = b"strategic_supporters";
    const KEEPERS: vector<u8> = b"keepers";
    const ECOSYSTEM_GROWTH_POOL: vector<u8> = b"ecosystem_growth_pool";
    const ADVISORS: vector<u8> = b"advisors";
    const TEAM: vector<u8> = b"team";
    const TOKEN_TREASURY: vector<u8> = b"token_treasury";
    const LIQUIDITY: vector<u8> = b"liquidity";

    // === Public package functions ===
    /// Returns the default minting schedule
    public(package) fun default<T>(): vector<ScheduleEntry<T>> {
        vector[
            // ZERO MINT
            treasury::create_entry(
                vector[STRATEGIC_SUPPORTERS.to_string(), TOKEN_TREASURY.to_string(), LIQUIDITY.to_string()],
                vector[95_999_000_000_000_128, 127_499_000_000_000_768, 150_000_000_000_000_000],
                1, 172800000, 0,
            ),
            // Stage 1
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string(), STRATEGIC_SUPPORTERS.to_string(), TOKEN_TREASURY.to_string()],
                vector[600_000_000_000_000, 600_000_000_000_000, 1_920_000_000_000_000, 404_762_000_000_000],
                45, 172800000, 0,
            ),
            // Stage 2
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string(), STRATEGIC_SUPPORTERS.to_string(), ADVISORS.to_string(), TEAM.to_string(), TOKEN_TREASURY.to_string()],
                vector[593_333_333_333_333, 600_000_000_000_000, 1_653_333_333_333_333, 49_855_555_555_560, 375_000_000_000_000, 404_762_000_000_000],
                45, 172800000, 0,
            ),
            // Stage 3
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string(), STRATEGIC_SUPPORTERS.to_string(), ADVISORS.to_string(), TEAM.to_string(), TOKEN_TREASURY.to_string()],
                vector[580_000_000_000_000, 600_000_000_000_000, 1_653_333_333_333_333, 50_000_000_000_000, 375_000_000_000_000, 404_761_888_888_888],
                90, 172800000, 0,
            ),
            // Stage 4
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string(), STRATEGIC_SUPPORTERS.to_string(), ADVISORS.to_string(), TEAM.to_string(), TOKEN_TREASURY.to_string()],
                vector[566_666_666_666_666, 250_000_000_000_000, 826_666_666_666_666, 81_666_666_666_666, 612_500_000_000_000, 404_761_888_888_888],
                90, 172800000, 0,
            ),
            // Stage 5
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string(), ADVISORS.to_string(), TEAM.to_string(), TOKEN_TREASURY.to_string()],
                vector[553_333_333_333_333, 243_333_333_333_333, 113_333_333_333_333, 850_000_000_000_000, 404_761_925_925_925],
                135, 172800000, 0,
            ),
            // Stage 6
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string(), ADVISORS.to_string(), TEAM.to_string(), TOKEN_TREASURY.to_string()],
                vector[540_000_000_000_000, 236_666_666_666_666, 113_333_333_333_333, 850_000_000_000_000, 404_761_925_925_925],
                135, 172800000, 0,
            ),
            // Stage 7
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string(), ADVISORS.to_string(), TEAM.to_string(), TOKEN_TREASURY.to_string()],
                vector[526_666_666_666_666, 230_000_000_000_000, 113_333_333_333_333, 850_000_000_000_000, 404_761_925_925_925],
                135, 172800000, 0,
            ),
            // Stage 8
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string(), TOKEN_TREASURY.to_string()],
                vector[513_333_333_333_333, 223_333_333_333_333, 404_761_925_925_925],
                135, 172800000, 0,
            ),
            // Stage 9
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string(), TOKEN_TREASURY.to_string()],
                vector[500_000_000_000_000, 216_666_666_666_666, 404_761_777_777_777],
                135, 172800000, 0,
            ),
            // Stage 10
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string()],
                vector[486_666_666_666_666, 210_000_000_000_000],
                135, 172800000, 0,
            ),
            // Stage 11
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string()],
                vector[473333333333333, 203333333333333],
                135, 172800000, 0,
            ),
            // Stage 12
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string()],
                vector[460_000_000_000_000, 196_666_666_666_666],
                135, 172800000, 0,
            ),
            // Stage 13
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string()],
                vector[446_666_666_666_666, 190_000_000_000_000],
                135, 172800000, 0,
            ),
            // Stage 14
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string()],
                vector[433_333_333_333_333, 183_333_333_333_333],
                135, 172800000, 0,
            ),
            // Stage 15
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string()],
                vector[428_333_296_089_385, 175_000_000_000_000],
                179, 172800000, 0,
            ),
            // Stage 16
            treasury::create_entry(
                vector[KEEPERS.to_string(), ECOSYSTEM_GROWTH_POOL.to_string()],
                vector[426_340_000_000_640, 173_000_000_000_448],
                1, 172800000, 0,
            ),
        ]
    }
} 

#[test_only]
module blhnsuicntrtctkn::schedule_tests {
    use blhnsuicntrtctkn::chirp::{Self, CHIRP, Vault};
    use std::string::{String};
    use sui::clock::{Self, Clock};
    use sui::coin::{Self};
    use sui::test_scenario::{Self, Scenario};
    use sui::test_utils;

    const STRATEGIC_SUPPORTERS: vector<u8> = b"strategic_supporters";
    const KEEPERS: vector<u8> = b"keepers";
    const ECOSYSTEM_GROWTH_POOL: vector<u8> = b"ecosystem_growth_pool";
    const ADVISORS: vector<u8> = b"advisors";
    const TEAM: vector<u8> = b"team";
    const TOKEN_TREASURY: vector<u8> = b"token_treasury";
    const LIQUIDITY: vector<u8> = b"liquidity";

    const PUBLISHER: address = @0xA;
    const RANDOM_PERSON: address = @0xB;

    #[test]
    fun test_default_schedule() {
        let mut scenario = test_scenario::begin(PUBLISHER);
        {
            chirp::init_for_testing(scenario.ctx());
            clock::share_for_testing(clock::create_for_testing(scenario.ctx()));
        };
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            let mut clock: Clock = scenario.take_shared();

            // First mint might happen immediately
            chirp::mint(&mut vault, &clock, scenario.ctx());
            clock.increment_for_testing(172800000);

            test_scenario::return_shared(vault);
            test_scenario::return_shared(clock);
        };
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 0, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 0, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 95_999_000_000_000_128, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 0, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 0, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 127_499_000_000_000_768, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(45, &mut scenario); // stage 1
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 27_000_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 27_000_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 182_399_000_000_000_128, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 0, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 0, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 145_713_290_000_000_768, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(45, &mut scenario); // stage 2
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 53_699_999_999_999_985, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 54_000_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 256_799_000_000_000_113, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 2_243_500_000_000_200, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 16_875_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 163_927_580_000_000_768, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(90, &mut scenario); // stage 3
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 105_899_999_999_999_985, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 108_000_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 405_599_000_000_000_083, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 6_743_500_000_000_200, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 50_625_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 200_356_150_000_000_688, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(90, &mut scenario); // stage 4
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 156_899_999_999_999_925, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 130_500_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 479_999_000_000_000_023, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 14_093_500_000_000_140, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 105_750_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 236_784_720_000_000_608, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(135, &mut scenario); // stage 5
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 231_599_999_999_999_880, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 163_349_999_999_999_955, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 479_999_000_000_000_023, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 29_393_500_000_000_095, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 220_500_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 291_427_580_000_000_483, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(135, &mut scenario); // stage 6
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 304_499_999_999_999_880, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 195_299_999_999_999_865, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 479_999_000_000_000_023, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 44_693_500_000_000_050, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 335_250_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 346_070_440_000_000_358, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(135, &mut scenario); // stage 7
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 375_599_999_999_999_790, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 226_349_999_999_999_865, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 479_999_000_000_000_023, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 59_993_500_000_000_005, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 450_000_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 400_713_300_000_000_233, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(135, &mut scenario); // stage 8
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 444_899_999_999_999_745, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 256_499_999_999_999_820, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 479_999_000_000_000_023, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 59_993_500_000_000_005, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 450_000_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 455_356_160_000_000_108, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(135, &mut scenario); // stage 9
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 512_399_999_999_999_745, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 285_749_999_999_999_730, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 479_999_000_000_000_023, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 59_993_500_000_000_005, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 450_000_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 509_999_000_000_000_003, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(135, &mut scenario); // stage 10
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 578_099_999_999_999_655, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 314_099_999_999_999_730, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 479_999_000_000_000_023, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 59_993_500_000_000_005, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 450_000_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 509_999_000_000_000_003, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(135, &mut scenario); // stage 11
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 641_999_999_999_999_610, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 341_549_999_999_999_685, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 479_999_000_000_000_023, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 59_993_500_000_000_005, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 450_000_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 509_999_000_000_000_003, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(135, &mut scenario); // stage 12
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 704_099_999_999_999_610, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 368_099_999_999_999_595, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 479_999_000_000_000_023, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 59_993_500_000_000_005, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 450_000_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 509_999_000_000_000_003, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(135, &mut scenario); // stage 13
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 764_399_999_999_999_520, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 393_749_999_999_999_595, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 479_999_000_000_000_023, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 59_993_500_000_000_005, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 450_000_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 509_999_000_000_000_003, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(135, &mut scenario); // stage 14
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 822_899_999_999_999_475, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 418_499_999_999_999_550, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 479_999_000_000_000_023, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 59_993_500_000_000_005, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 450_000_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 509_999_000_000_000_003, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(179, &mut scenario); // stage 15
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 899_571_659_999_999_390, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 449_824_999_999_999_550, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 479_999_000_000_000_023, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 59_993_500_000_000_005, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 450_000_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 509_999_000_000_000_003, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            test_scenario::return_shared(vault);
        };
        batch_mint(1, &mut scenario); // stage 16
        scenario.next_tx(RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            assert_pool_eq_chirp_coin(&mut vault, KEEPERS.to_string(), 899_998_000_000_000_030, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ECOSYSTEM_GROWTH_POOL.to_string(), 449_997_999_999_999_998, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, STRATEGIC_SUPPORTERS.to_string(), 479_999_000_000_000_023, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, ADVISORS.to_string(), 59_993_500_000_000_005, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TEAM.to_string(), 450_000_000_000_000_000, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, TOKEN_TREASURY.to_string(), 509_999_000_000_000_003, &scenario);
            assert_pool_eq_chirp_coin(&mut vault, LIQUIDITY.to_string(), 150_000_000_000_000_000, &scenario);
            // Totally minted: 2_999_987_500_000_000_059 (12_499_999_999_941 left)
            test_scenario::return_shared(vault);
        };
        scenario.end();
    }

    /// Asserts that the CHIRP pool's value matches the expected value.
    fun assert_pool_eq_chirp_coin(vault: &mut Vault, name: String, expected_value: u64, scenario: &Scenario) {
        let owner = vault.get_address_pool(name);
        test_utils::assert_eq(total_coins(owner, scenario), expected_value);
    }

    /// Mints the specified number of epochs of CHIRP coins.
    fun batch_mint(mut number_of_epochs: u64, scenario: &mut test_scenario::Scenario) {
        test_scenario::next_tx(scenario, RANDOM_PERSON);
        {
            let mut vault: Vault = scenario.take_shared();
            let mut clock: Clock = scenario.take_shared();

            while (number_of_epochs > 0) {
                chirp::mint(&mut vault, &clock, scenario.ctx());
                clock.increment_for_testing(172800000);
                number_of_epochs = number_of_epochs - 1;
            };

            test_scenario::return_shared(vault);
            test_scenario::return_shared(clock);
        };
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
