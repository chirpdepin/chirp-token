module blhnsuicntrtctkn::chirp {
    use std::debug;
    use sui::coin;
    use sui::vec_map;
    use sui::vec_map::VecMap;

    /// Decimals of CHIRP tokens
    const CoinDecimals: u8 = 10;

    /// Coin symbol in favor of ISO 4217
    const CoinSymbol: vector<u8> = b"CHIRP";

    /// Coin human readable name
    const CoinName: vector<u8> = b"Chirp Token";

    /// Coin human readable description
    const CoinDescription: vector<u8> = b"Chirp token description";

    /// Stages
    public struct Schedule has key, store {
        id: UID,
        stages: VecMap<u8, Stage>
    }

    public struct Stage has key, store {
        id: UID,
        epoch_start: u8,
        epoch_end: u8,
        keepers_distribution: u64,
        ecosystem_growth_pool_distribution: u64,
        investors_distribution: u64,
        advisors_distribution: u64,
        team_distribution: u64,
        token_treasury_distribution: u64,
        liquidity_distribution: u64,
    }

    public struct CHIRP has drop {}

    /// Module initializer is called once on module publish. A mint
    /// cap is sent to the publisher, who then controls minting
    fun init(witness: CHIRP, ctx: &mut TxContext) {
        let (mintcap, metadata) = coin::create_currency(witness, CoinDecimals, CoinSymbol, CoinName, CoinDescription, option::none(), ctx);
        transfer::public_freeze_object(metadata);

        transfer::public_transfer(mintcap, tx_context::sender(ctx));
        let schedule = crate_schedule(ctx);

        transfer::transfer(schedule, tx_context::sender(ctx));
    }

    // ======================= Createing Schedule =======================
    /// Create Schedule
    fun crate_schedule(ctx: &mut TxContext) : Schedule {
        let stagesVecMap = create_stages(ctx);
        Schedule {
            id: object::new(ctx),
            stages: stagesVecMap,
        }
    }

    /// Creates different stages of the coin
    fun create_stages(ctx: &mut TxContext) : VecMap<u8, Stage> {
        let mut vec_map = vec_map::empty<u8, Stage>();
        // vec_map::insert(&mut vec_map, 0, stage_with_certain_params(1, 45, 60029, 60028, 192030, 0, 0, 45021, 0));
        vec_map::insert(&mut vec_map, 1, create_stage_with_certain_params(ctx,1, 45, 59362, 59980, 165345, 9996, 37509, 45029, 0));
        vec_map::insert(&mut vec_map, 2, create_stage_with_certain_params(ctx,46, 70, 59362, 59980, 165345, 9996, 37509, 45029, 0));
        return vec_map
    }

    /// Returns the coin stage with certain parameters
    fun create_stage_with_certain_params(ctx: &mut TxContext, epoch_start: u8, epoch_end: u8, keepers_distribution: u64,
                                         ecosystem_growth_pool_distribution: u64,
                                         investors_distribution: u64,
                                         advisors_distribution: u64,
                                         team_distribution: u64,
                                         token_treasury_distribution: u64,
                                         liquidity_distribution: u64): Stage {
        return  Stage {
            id: object::new(ctx),
            epoch_start,
            epoch_end,
            keepers_distribution,
            ecosystem_growth_pool_distribution,
            investors_distribution,
            advisors_distribution,
            team_distribution,
            token_treasury_distribution,
            liquidity_distribution
        }
    }
    // =================================================================

    public fun scheduled_mint(schedule: &Schedule): u8 {
        let key = 1u8;
        let stage = vec_map::get(&schedule.stages, &key);
        return stage.epoch_end
    }

    #[test]
    public fun scheduled_mint_test() {
        let publisher = @0xA;
        let someNonPuplisher = @0xB;

        let mut scenario = test_scenario::begin(publisher);
        {
            test_init(ctx(&mut scenario))
        };

        //create Schedule
        scenario.next_tx(publisher);
        {
            let schedule = crate_schedule(ctx(&mut scenario));
            transfer::transfer(schedule, publisher);
        };
        
        scenario.next_tx(publisher);
        {
            let schedule = scenario.take_from_sender<Schedule>();
            scheduled_mint(&schedule);
            transfer::transfer(schedule, someNonPuplisher);
        };

        scenario.next_tx(someNonPuplisher);
        {
            let schedule = scenario.take_from_address<Schedule>(publisher);
            transfer::transfer(schedule, someNonPuplisher);

            let schedule = scenario.take_from_address<Schedule>(someNonPuplisher);
            let key = 1u8;
            let stage = vec_map::get(&schedule.stages, &key);
            debug::print(stage);
            transfer::transfer(schedule, someNonPuplisher);
        };

        scenario.end();
    }

    #[test_only]
    use sui::test_scenario::{Self, next_tx, ctx};

    #[test_only]
    /// Wrapper of module initializer for testing
    public fun test_init(ctx: &mut TxContext) {
        init(CHIRP{}, ctx)
    }

}
