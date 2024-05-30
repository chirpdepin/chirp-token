/// This module implements the default minting schedule of CHIRP token
module blhnsuicntrtctkn::schedule {
    // === Imports ===
    use blhnsuicntrtctkn::treasury::{Self, ScheduleEntry};

    // === Constants ===
    const KEEPERS: address = @0xbe5e7cd649c93c432e8f0b761d4640e03d6a6db37e04c4c70b87b37596adfc55;
    const KEEPERS_GROWTH: address = @0x1edc6ce4230130ace71a2280bcfe43ba161bf9754080fe224aff0f3849d7c30b;
    const INVESTORS: address = @0x3000c7fbfb1c83abf8cd86f3a637bba37a720d60812d7d5b0ec497f553d50830;
    const TOKEN_TREASURY: address = @0xded0cfc31d035545273f4cb9dd0648c52575062c9a4e37432c6ca3d5579f7a83;
    const CHIRP_TEAM: address = @0xb67d8af06fe17d01db643428947baa6f976975254feedb5db9370f9fbd1dc233;
    const STRATEGIC_ADVISORS: address = @0x7e8bd38d38b137eda219c11d2f17a5f59a5d9a974d6dac8ce280a36f3f87fb17;
    const LIQUIDITY: address = @0xc85c58c6669e2139524bb214942d5d3cd252c81692ad58d246bf7831e16b68d7;

    // === Public package functions ===
    /// Returns the default minting schedule
    public(package) fun default<T>(): vector<ScheduleEntry<T>> {
        vector[
            // ZERO MINT
            treasury::create_entry(
                vector[INVESTORS, TOKEN_TREASURY, LIQUIDITY],
                vector[cents(9_600_000), cents(4_500_000), cents(15_000_000)],
                1, 172800000, 0,
            ),
            // Stage 1
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH, INVESTORS, TOKEN_TREASURY],
                vector[cents(60_029), cents(60_028), cents(192_030), cents(45_021)],
                45, 172800000, 0,
            ),
            // Stage 2
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH, INVESTORS, STRATEGIC_ADVISORS, CHIRP_TEAM, TOKEN_TREASURY],
                vector[cents(59_362), cents(59_980), cents(165_345), cents(9_996), cents(37_509), cents(45_029)],
                45, 172800000, 0,
            ),
            // Stage 3
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH, INVESTORS, STRATEGIC_ADVISORS, CHIRP_TEAM, TOKEN_TREASURY],
                vector[cents(58_012), cents(60_019), cents(165_355), cents(9_986), cents(37_486), cents(45_014)],
                90, 172800000, 0,
            ),
            // Stage 4
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH, INVESTORS, STRATEGIC_ADVISORS, CHIRP_TEAM, TOKEN_TREASURY],
                vector[cents(56_639), cents(25_015), cents(82_672), cents(16_319), cents(61_269), cents(45_006)],
                90, 172800000, 0,
            ),
            // Stage 5
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH, STRATEGIC_ADVISORS, CHIRP_TEAM, TOKEN_TREASURY],
                vector[cents(55_351), cents(24_349), cents(22_675), cents(85_012), cents(45_016)],
                135, 172800000, 0,
            ),
            // Stage 6
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH, STRATEGIC_ADVISORS, CHIRP_TEAM, TOKEN_TREASURY],
                vector[cents(53_991), cents(23_658), cents(22_645), cents(85_013), cents(45_015)],
                135, 172800000, 0,
            ),
            // Stage 7
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH, STRATEGIC_ADVISORS, CHIRP_TEAM, TOKEN_TREASURY],
                vector[cents(52_664), cents(22_993), cents(22_641), cents(84_994), cents(44_982)],
                135, 172800000, 0,
            ),
            // Stage 8
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH, TOKEN_TREASURY],
                vector[cents(51_335), cents(22_350), cents(45_026)],
                135, 172800000, 0,
            ),
            // Stage 9
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH, TOKEN_TREASURY],
                vector[cents(50_007), cents(21_665), cents(29_980)],
                135, 172800000, 0,
            ),
            // Stage 10
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH],
                vector[cents(48_680), cents(21_015)],
                135, 172800000, 0,
            ),
            // Stage 11
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH],
                vector[cents(47_304), cents(20_339)],
                135, 172800000, 0,
            ),
            // Stage 12
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH],
                vector[cents(45_991), cents(19_690)],
                135, 172800000, 0,
            ),
            // Stage 13
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH],
                vector[cents(44_689), cents(19_013)],
                135, 172800000, 0,
            ),
            // Stage 14
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH],
                vector[cents(43_324), cents(18_320)],
                135, 172800000, 0,
            ),
            // Stage 15
            treasury::create_entry(
                vector[KEEPERS, KEEPERS_GROWTH],
                vector[cents(42_828), cents(17_489)],
                180, 172800000, 0,
            ),
        ]
    }

    // === Private functions ===
    /// Returns the coin value in CHIRP cents
    fun cents(value: u64): u64 {
        value * 10000000000u64
    }

    #[test_only] public fun chirp_team(): address { CHIRP_TEAM }
    #[test_only] public fun investors(): address { INVESTORS }
    #[test_only] public fun keepers_growth(): address { KEEPERS_GROWTH }
    #[test_only] public fun keepers(): address { KEEPERS }
    #[test_only] public fun liquidity(): address { LIQUIDITY }
    #[test_only] public fun strategic_advisors(): address { STRATEGIC_ADVISORS }
    #[test_only] public fun treasury(): address { TOKEN_TREASURY }
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
            // After the initial zero mint, the first mint's epoch lasts 172,800,000 milliseconds
            clock.increment_for_testing(172800000);

            test_scenario::return_shared(treasury);
            test_scenario::return_shared(clock);
        };
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(0), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(0), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(9_600_000), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(0), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(0), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(4_500_000), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(45, &mut scenario); // stage 1
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(2_701_305), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(2_701_260), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(18_241_350), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(0), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(0), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(6_525_945), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(45, &mut scenario); // stage 2
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(5_372_595), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(5_400_360), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(25_681_875), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(449_820), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(1_687_905), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(8_552_250), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(90, &mut scenario); // stage 3
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(10_593_675), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(10_802_070), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(40_563_825), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(1_348_560), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(5_061_645), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(12_603_510), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(90, &mut scenario); // stage 4
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(15_691_185), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(13_053_420), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(48_004_305), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(2_817_270), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(10_575_855), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(16_654_050), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 5
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(23_163_570), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(16_340_535), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(48_004_305), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(5_878_395), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(22_052_475), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(22_731_210), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 6
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(30_452_355), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(19_534_365), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(48_004_305), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(8_935_470), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(33_529_230), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(28_808_235), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 7
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(37_561_995), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(22_638_420), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(48_004_305), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(11_992_005), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(45_003_420), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(34_880_805), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 8
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(44_492_220), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(25_655_670), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(48_004_305), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(11_992_005), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(45_003_420), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(40_959_315), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 9
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(51_243_165), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(28_580_445), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(48_004_305), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(11_992_005), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(45_003_420), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(45_006_615), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 10
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(57_814_965), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(31_417_470), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(48_004_305), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(11_992_005), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(45_003_420), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(45_006_615), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 11
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(64_201_005), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(34_163_235), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(48_004_305), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(11_992_005), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(45_003_420), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(45_006_615), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 12
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(70_409_790), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(36_821_385), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(48_004_305), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(11_992_005), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(45_003_420), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(45_006_615), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 13
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(76_442_805), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(39_388_140), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(48_004_305), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(11_992_005), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(45_003_420), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(45_006_615), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(135, &mut scenario); // stage 14
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(82_291_545), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(41_861_340), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(48_004_305), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(11_992_005), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(45_003_420), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(45_006_615), &scenario);
            assert_eq_chirp_coin(schedule::liquidity(), cents(15_000_000), &scenario);
        };
        batch_mint(180, &mut scenario); // stage 15
        scenario.next_tx(RANDOM_PERSON);
        {
            assert_eq_chirp_coin(schedule::keepers(), cents(90_000_585), &scenario);
            assert_eq_chirp_coin(schedule::keepers_growth(), cents(45_009_360), &scenario);
            assert_eq_chirp_coin(schedule::investors(), cents(48_004_305), &scenario);
            assert_eq_chirp_coin(schedule::strategic_advisors(), cents(11_992_005), &scenario);
            assert_eq_chirp_coin(schedule::chirp_team(), cents(45_003_420), &scenario);
            assert_eq_chirp_coin(schedule::treasury(), cents(45_006_615), &scenario);
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
