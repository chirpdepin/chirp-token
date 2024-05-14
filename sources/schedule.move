/// This module implements the default minting schedule of CHIRP token
module blhnsuicntrtctkn::schedule {
    // === Imports ===
    use blhnsuicntrtctkn::treasury::{Self, ScheduleEntry};

    // === Constants ===
    const KEEPERS: address = @0x02ab60f0e82d58cbd047dd27d9e09d08a9b41d8d08f2f08bd0f25424d08c7f77;
    const ECOSYSTEM_GROWTH_POOL: address = @0x021e2fcdb57234a42a588654bc2b31fa1a53896cdc11b81d9332a5287cd0f248;
    const EARLY_SUPPORTERS: address = @0x6bf9e238beb4391690ec02ce41cb480f91a78178819574bf6e9882cc238920d3;
    const TOKEN_TREASURY: address = @0xc196c590ff20d63d17271c8dcceafc3432a47f629292fa9f552f5c8c4ea92b4b;
    const TEAM: address = @0xd841709b605bafdcb27d544b0a76e35cd3e904a6b6f5b4347e836c1dd24f6306;
    const ADVISORS: address = @0x573a0841ab7c22c1e5c714c4e5ab1c440546c8c36c2b94eba62665c5f75237d6;
    const LIQUIDITY: address = @0x9575fc19fedcd62a406385dcc7607c567d91a6df94e2eea9a941051bbb6ce65e;

    // === Public package functions ===
    /// Returns the default minting schedule
    public(package) fun default<T>(): vector<ScheduleEntry<T>> {
        vector[
            // ZERO MINT
            treasury::create_entry(
                vector[EARLY_SUPPORTERS, TOKEN_TREASURY, LIQUIDITY],
                vector[cents(9_600_000), cents(4_500_000), cents(15_000_000)],
                1, 1, 0,
            ),
            // Stage 1
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL, EARLY_SUPPORTERS, TOKEN_TREASURY],
                vector[cents(59_973), cents(59_972), cents(192_004), cents(42_837)],
                45, 172800000, 0,
            ),
            // Stage 2
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL, EARLY_SUPPORTERS, ADVISORS, TEAM, TOKEN_TREASURY],
                vector[cents(59_354), cents(59_971), cents(165_343), cents(9_980), cents(37_537), cents(42_837)],
                45, 172800000, 0,
            ),
            // Stage 3
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL, EARLY_SUPPORTERS, ADVISORS, TEAM, TOKEN_TREASURY],
                vector[cents(57_989), cents(59_991), cents(165_352), cents(10_015), cents(37_507), cents(42_865)],
                90, 172800000, 0,
            ),
            // Stage 4
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL, EARLY_SUPPORTERS, ADVISORS, TEAM, TOKEN_TREASURY],
                vector[cents(56_665), cents(25_009), cents(82_688), cents(16_334), cents(61_227), cents(42_864)],
                90, 172800000, 0,
            ),
            // Stage 5
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL, ADVISORS, TEAM, TOKEN_TREASURY],
                vector[cents(55_319), cents(24_321), cents(22_652), cents(84_979), cents(42_844)],
                135, 172800000, 0,
            ),
            // Stage 6
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL, ADVISORS, TEAM, TOKEN_TREASURY],
                vector[cents(54_007), cents(23_676), cents(22_667), cents(84_978), cents(42_856)],
                135, 172800000, 0,
            ),
            // Stage 7
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL, ADVISORS, TEAM, TOKEN_TREASURY],
                vector[cents(52_689), cents(23_017), cents(22_666), cents(85_012), cents(42_881)],
                135, 172800000, 0,
            ),
            // Stage 8
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL, TOKEN_TREASURY],
                vector[cents(51_318), cents(22_325), cents(42_863)],
                135, 172800000, 0,
            ),
            // Stage 9
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL, TOKEN_TREASURY],
                vector[cents(49_999), cents(21_644), cents(42_880)],
                135, 172800000, 0,
            ),
            // Stage 10
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL],
                vector[cents(48_683), cents(20_997)],
                135, 172800000, 0,
            ),
            // Stage 11
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL],
                vector[cents(47_319), cents(20_326)],
                135, 172800000, 0,
            ),
            // Stage 12
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL],
                vector[cents(46_019), cents(19_681)],
                135, 172800000, 0,
            ),
            // Stage 13
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL],
                vector[cents(44_654), cents(19_009)],
                135, 172800000, 0,
            ),
            // Stage 14
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL],
                vector[cents(43_297), cents(18_320)],
                135, 172800000, 0,
            ),
            // Stage 15
            treasury::create_entry(
                vector[KEEPERS, ECOSYSTEM_GROWTH_POOL],
                vector[cents(42_827), cents(17_475)],
                180, 172800000, 0,
            ),
        ]
    }

    // === Private functions ===
    /// Returns the coin value in CHIRP cents
    fun cents(value: u64): u64 {
        value * 10000000000u64
    }

    #[test_only] public fun team(): address { TEAM }
    #[test_only] public fun early_supporters(): address { EARLY_SUPPORTERS }
    #[test_only] public fun ecosystem_growth_pool(): address { ECOSYSTEM_GROWTH_POOL }
    #[test_only] public fun keepers(): address { KEEPERS }
    #[test_only] public fun liquidity(): address { LIQUIDITY }
    #[test_only] public fun advisors(): address { ADVISORS }
    #[test_only] public fun token_treasury(): address { TOKEN_TREASURY }
} 

#[test_only]
module blhnsuicntrtctkn::schedule_tests {
    use blhnsuicntrtctkn::chirp::{Self, CHIRP};
    use blhnsuicntrtctkn::treasury::{Treasury};
    use blhnsuicntrtctkn::schedule::{Self};
    use sui::clock::{Self, Clock};
    use sui::coin::{Self};
    use sui::test_scenario;
    use sui::test_utils;

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
            let mut treasury: Treasury<CHIRP> = scenario.take_shared();
            let mut clock: Clock = scenario.take_shared();

            // First mint might happen immediately
            chirp::mint(&mut treasury, &clock, scenario.ctx());
            // The first mint's epoch duration is 1 millisecond
            clock.increment_for_testing(1);

            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(0), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(0), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(9_600_000), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(0), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(0), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(4_500_000), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(45, &mut scenario); // stage 1
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(2_698_785), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(2_698_740), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(18_240_180), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(0), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(0), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(6_427_665), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(45, &mut scenario); // stage 2
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(5_369_715), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(5_397_435), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(25_680_615), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(449_100), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(1_689_165), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(8_355_330), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(90, &mut scenario); // stage 3
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(10_588_725), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(10_796_625), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(40_562_295), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(1_350_450), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(5_064_795), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(12_213_180), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(90, &mut scenario); // stage 4
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(15_688_575), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(13_047_435), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(48_004_215), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(2_820_510), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(10_575_225), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(16_070_940), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 5
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(23_156_640), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(16_330_770), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(48_004_215), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(5_878_530), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(22_047_390), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(21_854_880), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 6
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(30_447_585), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(19_527_030), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(48_004_215), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(8_938_575), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(33_519_420), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(27_640_440), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 7
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(37_560_600), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(22_634_325), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(48_004_215), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(11_998_485), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(44_996_040), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(33_429_375), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 8
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(44_488_530), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(25_648_200), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(48_004_215), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(11_998_485), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(44_996_040), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(39_215_880), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 9
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(51_238_395), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(28_570_140), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(48_004_215), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(11_998_485), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(44_996_040), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(45_004_680), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 10
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(57_810_600), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(31_404_735), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(48_004_215), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(11_998_485), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(44_996_040), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(45_004_680), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 11
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(64_198_665), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(34_148_745), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(48_004_215), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(11_998_485), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(44_996_040), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(45_004_680), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 12
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(70_411_230), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(36_805_680), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(48_004_215), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(11_998_485), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(44_996_040), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(45_004_680), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 13
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(76_439_520), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(39_371_895), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(48_004_215), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(11_998_485), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(44_996_040), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(45_004_680), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 14
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(82_284_615), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(41_845_095), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(48_004_215), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(11_998_485), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(44_996_040), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(45_004_680), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(180, &mut scenario); // stage 15
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(89_993_475), &scenario);
            assert_eq_chirp_coin(schedule::ecosystem_growth_pool(), cents(44_990_595), &scenario);
            assert_eq_chirp_coin(schedule::early_supporters(), cents(48_004_215), &scenario);
            assert_eq_chirp_coin(schedule::advisors(), cents(11_998_485), &scenario);
            assert_eq_chirp_coin(schedule::team(), cents(44_996_040), &scenario);
            assert_eq_chirp_coin(schedule::token_treasury(), cents(45_004_680), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        scenario.end();
    }

    /// Asserts that the value of the CHIRP coin held by the owner is equal to the expected value.
    fun assert_eq_chirp_coin(owner: address, expected_value: u64, scenario: &test_scenario::Scenario) {
        test_utils::assert_eq(total_coins(owner, scenario), expected_value);
    }

    /// Mints the specified number of epochs of CHIRP coins.
    fun batch_mint(mut number_of_epochs: u64, scenario: &mut test_scenario::Scenario) {
        test_scenario::next_tx(scenario, RANDOM_PERSON);
        {
            let mut treasury: Treasury<CHIRP> = scenario.take_shared();
            let mut clock: Clock = scenario.take_shared();

            while (number_of_epochs > 0) {
                chirp::mint(&mut treasury, &clock, scenario.ctx());
                clock.increment_for_testing(172800000);
                number_of_epochs = number_of_epochs - 1;
            };

            test_scenario::return_shared(treasury);
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

    /// Returns the coin value in CHIRP cents
    fun cents(value: u64): u64 {
        value * 10000000000u64
    }
}
