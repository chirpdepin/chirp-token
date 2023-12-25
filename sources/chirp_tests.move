#[test_only]
module blhnsuicntrtctkn::managed_tests {
    use blhnsuicntrtctkn::chirp::{Self, CHIRP};
    use sui::coin::TreasuryCap;
    use sui::test_scenario::{Self, next_tx, ctx};

    #[test]
    fun mint_burn() {
        // Initialize a mock sender address
        let publisher = @0xA;

        // Begins a multi transaction scenario with publisher as the sender
        let scenario = test_scenario::begin(publisher);
        
        // Run the managed coin module init function
        {
            chirp::test_init(ctx(&mut scenario))
        };

        // Mint a `Coin<CHIRP>` object
        next_tx(&mut scenario, publisher);
        {
            let treasurycap = test_scenario::take_from_sender<TreasuryCap<CHIRP>>(&scenario);
            chirp::mint(&mut treasurycap, 100, publisher, test_scenario::ctx(&mut scenario));
            test_scenario::return_to_address<TreasuryCap<CHIRP>>(publisher, treasurycap);
        };

        // Cleans up the scenario object
        test_scenario::end(scenario);
    }
}
